/*
 *                  X
 *       (0,0)             (800, 0)
 *          __________________
 *         |                  |
 *         |                  |
 *    Y    |                  |
 *         |                  |
 *         |                  |
 *         |__________________|
 *               TRDB_LTM
 *       (0,480)           (800,480)
 * Written by : Bo-Yun, Yu
 * Date: 2024.12.05
 */

#include <stdio.h>
#include <system.h> /* System definitions */
#include <unistd.h> /* For sleep function */
#include <sys/alt_irq.h>
#include <priv/alt_legacy_irq.h> /* Define alt_irq_register() */
#include <io.h>    /* Declare I/O functions */
#include ".\OLEDLib\NiosOledDrv.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "sys/alt_timestamp.h" /* For timer functions */

#define FIFO_SIZE 32  // Define FIFO buffer size
#define STACK_SIZE 512 // Define stack size
#define TP 10        // Define touch point size

// Segment patterns for numbers 0-9 on a 7-segment display
const alt_u8 SEG_PATTERN[17] = {
    0x3F,  // 0
    0x06,  // 1
    0x5B,  // 2
    0x4F,  // 3
    0x66,  // 4
    0x6D,  // 5
    0x7D,  // 6
    0x07,  // 7
    0x7F,  // 8
    0x6F,  // 9
    0x77,  // A
    0x7C,  // B
    0x39,  // C
    0x5E,  // D
    0x79,  // E
    0x71,   // F
    0x00    // Blank
};

typedef struct {
    int x;
    int y;
} TouchPoint;

TouchPoint fifo[FIFO_SIZE];
TouchPoint stack[STACK_SIZE];
int fifo_head = 0;
int fifo_tail = 0;
int stack_top = -1;
int LTMDisp[800 * 480]; // LTM display buffer
int touch_irq = 0;

// Check if FIFO is full
int is_fifo_full() {
    return ((fifo_head + 1) % FIFO_SIZE) == fifo_tail;
}

// Check if FIFO is empty
int is_fifo_empty() {
    return fifo_head == fifo_tail;
}

// Check if stack is full
int is_stack_full() {
    return stack_top >= STACK_SIZE - 1;
}

// Check if stack is empty
int is_stack_empty() {
    return stack_top < 0;
}

// Push data into FIFO
void fifo_push(int x, int y) {
    if (!is_fifo_full()) {
        fifo[fifo_head].x = x;
        fifo[fifo_head].y = y;
        fifo_head = (fifo_head + 1) % FIFO_SIZE;
    } else {
        printf("FIFO Buffer Full!\n");
    }
}

// Pop data from FIFO
TouchPoint fifo_pop() {
    TouchPoint point = {0, 0};
    if (!is_fifo_empty()) {
        point = fifo[fifo_tail];
        fifo_tail = (fifo_tail + 1) % FIFO_SIZE;
    }
    return point;
}

// Push data into stack
void stack_push(int x, int y) {
    if (!is_stack_full()) {
        stack[++stack_top].x = x;
        stack[stack_top].y = y;
    } else {
        printf("Stack Full!\n");
    }
}

// Pop data from stack
TouchPoint stack_pop() {
    TouchPoint point = {0, 0};
    if (!is_stack_empty()) {
        point = stack[stack_top--];
    }
    return point;
}

// Clear FIFO
void fifo_clear() {
    fifo_head = 0;
    fifo_tail = 0;
}

// Clear stack
void stack_clear() {
    stack_top = -1;
}

// Interrupt service routine
void touch_isr() {
    IOWR(TOUCHIRQ_BASE, 3, 0); // Clear edgecapture register bits
    int x = IORD(TOUCHY_BASE, 0);
    int y = 4096 - IORD(TOUCHX_BASE, 0);
    x = (x * 800) / 4096;
    y = (y * 480) / 4096;

    fifo_push(x, y); // Push touch coordinates into FIFO
    stack_push(x, y); // Push touch coordinates into stack
}

// Enable PIO interrupt
void DoEnablePIOint(void) {
    alt_irq_register(TOUCHIRQ_IRQ, 0, touch_isr); // Register interrupt handler
    IOWR(TOUCHIRQ_BASE, 2, 0x01);                // Enable TouchIRQ interrupt
    IOWR(TOUCHIRQ_BASE, 3, 0);                   // Clear edgecapture register bits
}

void print_input_data(float *input_data, int rows, int cols) {
    int i, j;
    if (input_data == NULL) {
        printf("Input data is NULL.\n");
        return;
    }

    printf("Input Data (%dx%d):\n", rows, cols);
    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols; j++) {
            printf("%0.0f ", input_data[i * cols + j]); // Print as 0 or 1
        }
        printf("\n"); // Newline after each row
    }
}

// Read binary file
float *read_bin_file(const char *filename, int size) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Failed to open file");
        exit(EXIT_FAILURE);
    }

    float *data = (float *)malloc(size * sizeof(float));
    if (!data) {
        perror("Failed to allocate memory");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    fread(data, sizeof(float), size, file);
    fclose(file);
    return data;
}

// Optimized fully connected (dense) layer with integrated ReLU activation
void DenseLayerReLU(float *input, int input_size, float *weights, float *biases, float *output, int output_size) {
    int i, j;

    for (i = 0; i < output_size; i++) {
        float sum = biases[i]; // Start with the bias

        for (j = 0; j < input_size; j++) {
            sum += input[j] * weights[j * output_size + i];
        }

        // Apply ReLU activation immediately
        output[i] = sum > 0 ? sum : 0;
    }
}

// Original DenseLayer function without ReLU (used for the output layer)
void DenseLayer(float *input, int input_size, float *weights, float *biases, float *output, int output_size) {
    int i, j;
    // Initialize output with biases
    memcpy(output, biases, output_size * sizeof(float));

    // Perform matrix-vector multiplication
    for (j = 0; j < input_size; j++) {
        float input_j = input[j];
        float *weight_row = &weights[j * output_size]; // Access weights row-wise
        for (i = 0; i < output_size; i++) {
            output[i] += input_j * weight_row[i];
        }
    }
}

// Optimized Softmax function
void Softmax(float *x, int size) {
    int i;
    float max_val = x[0];
    float sum_exp = 0.0f;

    // Find max value for numerical stability
    for (i = 1; i < size; i++) {
        if (x[i] > max_val) max_val = x[i];
    }

    // Compute exponentials and accumulate sum
    for (i = 0; i < size; i++) {
        x[i] = expf(x[i] - max_val);
        sum_exp += x[i];
    }

    // Normalize the exponentials
    float inv_sum_exp = 1.0f / sum_exp;
    for (i = 0; i < size; i++) {
        x[i] *= inv_sum_exp;
    }
}

// Function to display time_taken on 7-segment displays
void display_time_to_segments(double time_taken) {
    // Separate integer and fractional parts
    int int_part = (int)time_taken;                // Integer part (e.g., 0)
    int frac_part = (int)((time_taken - int_part) * 100); // Fractional part scaled to 4 digits (e.g., 6518)

    // Display integer part with decimal point on SEG3
    int decimal_point = SEG_PATTERN[int_part] | 0x80; // Add decimal point
    IOWR(SEG3_BASE, 0, ~decimal_point);

    // Extract and display fractional part digits
    int digit2 = frac_part % 10; // Extract least significant digit
    frac_part /= 10;

    int digit1 = frac_part % 10; // Extract next digit
    frac_part /= 10;

    int digit0 = frac_part % 10; // Extract next digit

    // Display digits on SEG2, SEG1, SEG0
    IOWR(SEG2_BASE, 0, ~SEG_PATTERN[digit0]); // Most significant fractional digit
    IOWR(SEG1_BASE, 0, ~SEG_PATTERN[digit1]); // Middle fractional digit
    IOWR(SEG0_BASE, 0, ~SEG_PATTERN[digit2]); // Least significant fractional digit
}

void display_probability_to_segments(double probability){
	int int_part = (int)probability;                // Integer part (e.g., 0)
	int frac_part = (int)((probability - int_part) * 100); // Fractional part scaled to 4 digits (e.g., 6518)

	// Extract and display fractional part digits
	int digit2 = frac_part % 10; // Extract least significant digit
	frac_part /= 10;

	int digit1 = frac_part;

	IOWR(SEG5_BASE, 0, ~SEG_PATTERN[digit1]); // Most significant fractional digit
	IOWR(SEG4_BASE, 0, ~SEG_PATTERN[digit2]); // Middle fractional digit
}

// Model inference function
int model_inference(float *input_data, float *fWei0, float *fBias0, float *fWei2, float *fBias2, float *fWei4, float *fBias4) {
    int i, j;

    // First layer with integrated ReLU activation
    float net1[128];

    for (i = 0; i < 128; i++) {
        float sum = fBias0[i]; // Start with the bias
        for (j = 0; j < 784; j++) {
            sum += input_data[j] * fWei0[j * 128 + i];
        }
        // Apply ReLU activation immediately
        net1[i] = sum > 0 ? sum : 0;
    }

    // Second layer with integrated ReLU activation
    float net2[128];

    for (i = 0; i < 128; i++) {
        float sum = fBias2[i]; // Start with the bias
        for (j = 0; j < 128; j++) {
            sum += net1[j] * fWei2[j * 128 + i];
        }
        // Apply ReLU activation immediately
        net2[i] = sum > 0 ? sum : 0;
    }

    // Third layer computations
    float net3[10];
    // Initialize net3 with biases
    memcpy(net3, fBias4, 10 * sizeof(float));

    // Compute net3
    for (i = 0; i < 10; i++) {
        for (j = 0; j < 128; j++) {
            net3[i] += net2[j] * fWei4[j * 10 + i];
        }
    }

    // Apply Softmax activation
    Softmax(net3, 10);

    // Find the predicted label
    int predicted_label = 0;
    float max_prob = net3[0];
    for (i = 1; i < 10; i++) {
        if (net3[i] > max_prob) {
            max_prob = net3[i];
            predicted_label = i;
        }
    }

    display_probability_to_segments(net3[predicted_label]);

    return predicted_label;
}

int main() {
    tAdafruit_GFX LTM;   /* Initialize Adafruit_GFX for LTM display */
    int i, j, dx, dy;
    unsigned int button_state;
    float normalized_frame[28 * 28]; // 28x28 normalized frame
    printf("LTM Touch demo!\n");
    DoEnablePIOint();
    Adafruit_GFX_init(&LTM, 800, 480, 0, LTMDisp); /* Initialize LTM */

    /* Set LTM_MM base address */
    IOWR(LTM_MM_IF_BASE, 0, &LTMDisp[0]); /* Set LTM display buffer */
    IOWR(LTM_MM_IF_BASE, 2, 1);           /* Enable LTM */

    OLED_Clear(&LTM); /* Clear LTM display */

    unsigned int timeS, timeE;
    int predicted_label;

    const char *weight_files[] = {
        "/mnt/rozipfs/Dense_0_weight.bin",
        "/mnt/rozipfs/Dense_2_weight.bin",
        "/mnt/rozipfs/Dense_4_weight.bin"
    };

    const char *bias_files[] = {
        "/mnt/rozipfs/Dense_0_bias.bin",
        "/mnt/rozipfs/Dense_2_bias.bin",
        "/mnt/rozipfs/Dense_4_bias.bin"
    };

    // Read all weights and biases at the beginning
    printf("Loading weights and biases...\n");
    float *fWei0 = read_bin_file(weight_files[0], 784 * 128);
    float *fBias0 = read_bin_file(bias_files[0], 128);
    float *fWei2 = read_bin_file(weight_files[1], 128 * 128);
    float *fBias2 = read_bin_file(bias_files[1], 128);
    float *fWei4 = read_bin_file(weight_files[2], 128 * 10);
    float *fBias4 = read_bin_file(bias_files[2], 10);

    printf("Weights and biases loaded successfully.\n");

    printf("Starting DNN model inference from flash...\n");
    IOWR(SEG0_BASE, 0, ~SEG_PATTERN[16]);
    IOWR(SEG1_BASE, 0, ~SEG_PATTERN[16]);
    IOWR(SEG2_BASE, 0, ~SEG_PATTERN[16]);
    IOWR(SEG3_BASE, 0, ~SEG_PATTERN[16]);
    IOWR(SEG4_BASE, 0, ~SEG_PATTERN[16]);
	IOWR(SEG5_BASE, 0, ~SEG_PATTERN[16]);
	IOWR(SEG6_BASE, 0, ~SEG_PATTERN[16]);
	IOWR(SEG7_BASE, 0, ~SEG_PATTERN[16]);

    alt_timestamp_start();
    unsigned long clock_freq = alt_timestamp_freq();
    unsigned long start, end;

    const int X_SCALE_NUM = 7;
	const int X_SCALE_DEN = 200;  // Simplified from 28/800
	const int Y_SCALE_NUM = 7;
	const int Y_SCALE_DEN = 120;  // Simplified from 28/480

    while (1) {
        button_state = IORD(BUTTON_BASE, 3);

        if (button_state == 0x2) {
            OLED_Clear(&LTM);
            stack_clear();
            fifo_clear();
            IOWR(BUTTON_BASE, 3, 0);
            IOWR(SEG0_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG1_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG2_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG3_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG4_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG5_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG6_BASE, 0, ~SEG_PATTERN[16]);
			IOWR(SEG7_BASE, 0, ~SEG_PATTERN[16]);
        }

        if (button_state == 0x4) {
            // Convert the 28x28 area into normalized_frame with row-column reversed
            for (i = 0; i < 28; i++) {
                int row_start = i * 800;
                int reversed_i = 27 - i;  // Precompute reversed index

                for (j = 0; j < 28; j++) {
                    unsigned int pixel_value = LTMDisp[row_start + j];

                    // Map the pixel value to normalized_value, either 1.0f or 0.0f
                    float normalized_value = (pixel_value == 0xFFFFFF) ? 1.0f : 0.0f;

                    // Store in normalized_frame with row-column reversed
                    normalized_frame[j * 28 + reversed_i] = normalized_value;
                }
            }
            // print_input_data(normalized_frame, 28, 28);
//            printf("Data saved successfully to normalized_frame with row-column reversed.\n");
            start = alt_timestamp();
            predicted_label = model_inference(normalized_frame, fWei0, fBias0, fWei2, fBias2, fWei4, fBias4);
            end = alt_timestamp();
            double time_taken = (double)(end - start) / clock_freq;
//            printf("Time taken: %.6lf seconds\n", time_taken);
            IOWR(SEG6_BASE, 0, ~SEG_PATTERN[predicted_label]);
            display_time_to_segments(time_taken);

            IOWR(BUTTON_BASE, 3, 0);
        }

        // Process data from FIFO
        if (!is_fifo_empty()) {
            TouchPoint point = fifo_pop();

            int tp_half = TP / 2;
            // Display touch point
            for (i = -tp_half; i < tp_half; i++) {
                int new_x = point.x + i;
                if (new_x < 0 || new_x >= 800) continue;

                for (j = -tp_half; j < tp_half; j++) {
                    int new_y = point.y + j;
                    if (new_y < 0 || new_y >= 480) continue;

                    LTMDisp[new_y * 800 + new_x] = 0xffffff;
                }
            }
        }

        // Process all touch points
		if (!is_stack_empty()) {
			TouchPoint point = stack_pop();

			// Map the coordinates to a 28x28 area using simplified fractions
			int mapped_x = (point.x * X_SCALE_NUM) / X_SCALE_DEN;
			int mapped_y = (point.y * Y_SCALE_NUM) / Y_SCALE_DEN;

			// Draw a 2x2 square around the mapped point
			for (dy = -1; dy <= 1; dy++) {
				int new_y = mapped_y + dy;
				if (new_y < 0 || new_y >= 28) continue;

				int row_start = new_y * 800;  // Precompute row start index

				for (dx = -1; dx <= 1; dx++) {
					int new_x = mapped_x + dx;
					if (new_x < 0 || new_x >= 28) continue;

					LTMDisp[row_start + new_x] = 0xFFFFFF;
				}
			}
		}
    }

    // Free allocated weights and biases before exiting
    free(fWei0);
    free(fBias0);
    free(fWei2);
    free(fBias2);
    free(fWei4);
    free(fBias4);

    return 0;
}
