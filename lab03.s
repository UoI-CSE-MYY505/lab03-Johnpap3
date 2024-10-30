# Conversion of RGB888 image to RGB565
# lab03 of MYY505 - Computer Architecture
# Department of Computer Engineering, University of Ioannina
# Aris Efthymiou

# This directive declares subroutines. Do not remove it!
.globl rgb888_to_rgb565, showImage

.data

image888:  # A rainbow-like image Red->Green->Blue->Red
    .byte 255, 0,     0
    .byte 255,  85,   0
    .byte 255, 170,   0
    .byte 255, 255,   0
    .byte 170, 255,   0
    .byte  85, 255,   0
    .byte   0, 255,   0
    .byte   0, 255,  85
    .byte   0, 255, 170
    .byte   0, 255, 255
    .byte   0, 170, 255
    .byte   0,  85, 255
    .byte   0,   0, 255
    .byte  85,   0, 255
    .byte 170,   0, 255
    .byte 255,   0, 255
    .byte 255,   0, 170
    .byte 255,   0,  85
    .byte 255,   0,   0
# repeat the above 5 times
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0

image565:
    .zero 512  # leave a 0.5Kibyte free space

.text
# -------- This is just for fun.
# Ripes has a LED matrix in the I/O tab. To enable it:
# - Go to the I/O tab and double click on LED Matrix.
# - Change the Height and Width (at top-right part of I/O window),
#     to the size of the image888 (6, 19 in this example)
# - This will enable the LED matrix
# - Uncomment the following and you should see the image on the LED matrix!
#    la   a0, image888
#    li   a1, LED_MATRIX_0_BASE
#    li   a2, LED_MATRIX_0_WIDTH
#    li   a3, LED_MATRIX_0_HEIGHT
#    jal  ra, showImage
# ----- This is where the fun part ends!

    la   a0, image888
    la   a3, image565
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb888_to_rgb565

    addi a7, zero, 10 
    ecall

# ----------------------------------------
# Subroutine showImage
# a0 - image to display on Ripes' LED matrix
# a1 - Base address of LED matrix
# a2 - Width of the image and the LED matrix
# a3 - Height of the image and the LED matrix
# Caution: Assumes the image and LED matrix have the
# same dimensions!
showImage:
    add  t0, zero, zero # row counter
showRowLoop:
    bge  t0, a3, outShowRowLoop
    add  t1, zero, zero # column counter
showColumnLoop:
    bge  t1, a2, outShowColumnLoop
    lbu  t2, 0(a0) # get red
    lbu  t3, 1(a0) # get green
    lbu  t4, 2(a0) # get blue
    slli t2, t2, 16  # place red at the 3rd byte of "led" word
    slli t3, t3, 8   #   green at the 2nd
    or   t4, t4, t3  # combine green, blue
    or   t4, t4, t2  # Add red to the above
    sw   t4, 0(a1)   # let there be light at this pixel
    addi a0, a0, 3   # move on to the next image pixel
    addi a1, a1, 4   # move on to the next LED
    addi t1, t1, 1
    j    showColumnLoop
outShowColumnLoop:
    addi t0, t0, 1
    j    showRowLoop
outShowRowLoop:
    jalr zero, ra, 0

# ----------------------------------------

rgb888_to_rgb565:
# ----------------------------------------
# Write your code here.
# You may move the "return" instruction (jalr zero, ra, 0).
 
    addi t0, zero, 0         # Αρχικοποίηση μετρητή βρόχου i = 0
    mul t2, a1, a2           # Υπολογισμός του συνολικού αριθμού pixels (πλάτος * ύψος)
    add t2, t2, zero         # t2 = a1 * a2

convert_loop:
    bge t0, t2, end_loop     # Εάν i >= συνολικά pixels, λήξη του βρόχου

    # Φόρτωση τιμών RGB888
    lb t3, 0(a0)             # Φόρτωση κόκκινου byte
    lb t4, 1(a0)             # Φόρτωση πράσινου byte
    lb t5, 2(a0)             # Φόρτωση μπλε byte

    # Μετατροπή κόκκινου (5 bits)
    srli t3, t3, 3           # Μετατόπιση δεξιά κατά 3 για τα 5 πιο σημαντικά bits του κόκκινου
    slli t3, t3, 11          # Μετατόπιση αριστερά κατά 11 για να τοποθετηθεί σωστά στο RGB565

    # Μετατροπή πράσινου (6 bits)
    srli t4, t4, 2           # Μετατόπιση δεξιά κατά 2 για τα 6 πιο σημαντικά bits του πράσινου
    slli t4, t4, 5           # Μετατόπιση αριστερά κατά 5 για να τοποθετηθεί σωστά στο RGB565

    # Μετατροπή μπλε (5 bits)
    srli t5, t5, 3           # Μετατόπιση δεξιά κατά 3 για τα 5 πιο σημαντικά bits του μπλε

    # Συνδυασμός κόκκινου, πράσινου και μπλε σε μία τιμή 16-bit RGB565
    or t6, t3, t4            # Συνδυασμός κόκκινου και πράσινου
    or t6, t6, t5            # Συνδυασμός με το μπλε

    # Αποθήκευση του αποτελέσματος RGB565 16-bit
    sh t6, 0(a3)             # Αποθήκευση του pixel RGB565 στην image565

    # Μετακίνηση στον επόμενο pixel στην πηγή και τον προορισμό
    addi a0, a0, 3           # Μετακίνηση του δείκτη πηγής κατά 3 bytes (RGB888)
    addi a3, a3, 2           # Μετακίνηση του δείκτη προορισμού κατά 2 bytes (RGB565)

    # Αύξηση του μετρητή βρόχου
    addi t0, t0, 1           # Αύξηση του μετρητή pixel
    j convert_loop           # Επανάληψη για το επόμενο pixel

end_loop:
	jalr zero, ra, 0         # Επιστροφή
    


