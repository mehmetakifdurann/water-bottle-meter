Water Bottle Fill Level Estimator

A MATLAB desktop application that opens a bottle image, detects the water level, and estimates the fill percentage. The application features a Turkish-language user interface and processes images entirely locally. No Python installation or additional MATLAB toolboxes are required.

Getting Started

1. Extract the ZIP file. In MATLAB, set the Current Folder to the su-sisesi-matlab directory.
2. Run the following command in the Command Window:

SuSisesiDoluluk

3. Click Fotoğraf Aç (Open Photo) to select a JPG, PNG, TIFF, or HEIC image. You can also click Örneği Aç (Open Example) to test the application using a synthetic bottle image with a 75% fill level.

The application was developed for MATLAB R2025a and later. Tests were performed on macOS using MATLAB R2026b Update 1.

Taking a Photo and Correcting the Results

For more reliable measurements, follow these recommendations:

* Bottle positioning: Keep a single bottle upright and ensure the entire bottle is visible in the image. Capture the photo from the side, preferably at the height of the bottle’s center. Leave some space on both sides.
* Background and lighting: Use a plain background and soft, even lighting to minimize shadows and reflections.
* Correcting the water level: If the turquoise water-level indicator appears in the wrong position, click Su Çizgisini İşaretle (Mark Water Level) and select the correct level in the image. This correction uses the automatically detected bottle profile.
* Manual bottle detection: If the application cannot detect the bottle boundaries, click Şişeyi Elle Çerçevele (Manually Select Bottle). Excluding the cap, select the top-left and then the bottom-right corner of a rectangle enclosing the bottle’s internal volume. Finally, click the water level.

In manual selection mode, the application displays the height-based fill percentage rather than a volume-based estimate.

If you know that a bottle is completely empty or full, you can indicate its level by selecting the bottom or top boundary, respectively.

Measurement Methodology

The automatic detection algorithm analyzes the bottle’s outer boundaries and horizontal image variations within its body.

The estimation process consists of the following steps:

1. Bottle boundary detection: The algorithm identifies the visible outline of the bottle.
2. Water-level detection: Horizontal variations in the bottle image are analyzed to estimate the position of the water surface.
3. Cross-sectional estimation: The bottle’s internal volume is approximated by weighting each image row according to the square of its visible width.
4. Volume estimation: The accumulated weight below the detected water level is divided by the total estimated volume weight.
5. Percentage calculation: The result is converted into an estimated fill percentage.

This method provides an approximate volume estimate when the camera is positioned directly in front of the bottle and its horizontal cross-sections maintain similar shapes.

Limitations

The accuracy of automatic detection depends heavily on image quality and bottle visibility.

* Opaque bottles: If the bottle is opaque or its label obscures the water level, the fill percentage cannot be determined from the image alone.
* Complex backgrounds: Patterned backgrounds may interfere with bottle boundary detection.
* Lighting conditions: Strong shadows, reflections, and uneven illumination may reduce detection accuracy.
* Camera angle: Tilted images or perspective distortion may affect the estimated volume.
* Bottle labels: Large or highly detailed labels can interfere with water-level detection.
* Completely full or empty bottles: If no visible water boundary exists, the application may not provide an automatic percentage.

Examples and Testing

The ornekler/ directory contains synthetic bottle images with known fill levels of 25%, 50%, and 75% by volume.

Across six synthetic tests, the maximum difference between the expected and estimated fill percentages was 0.6 percentage points.

Run the Tests

testBottleFill

Process an Image Without Opening the Interface

sonuc = estimateBottleFill("ornekler/sise_75.png");
disp(sonuc.percent)

The estimateBottleFill function returns a result structure containing the estimated percentage and diagnostic information.

If automatic measurement fails:

* sonuc.percent is set to NaN.
* sonuc.message contains an explanation of the failure.

Real-World Image Testing

Seven original JPEG images downloaded from Wikimedia Commons were tested using MATLAB R2026b Update 1.

No manual cropping or lighting corrections were applied before testing.

Important finding: Automatic detection failed to identify the bottle boundaries in all seven real-world images. Consequently, automatic mode did not produce a fill percentage for any of them.

Test Results

Image	Source Description	Manual Measurement
Shaded bottle image	Approximately half-filled	—
Labeled PET bottle	Approximately half-filled	52% height ratio
Bottle hanging above a street	Approximately half-filled	—
Transparent bottle	Empty	—
Bottle in a horizontal image	Small amount of residual water	—
Black-capped bottle	Full	—
Bottle on a glass surface	Contains water	85% height ratio

The manually measured percentages represent the ratio between the selected water level and the bottle’s total height.

These values are height-based measurements, not actual volumetric fill percentages.

Since the original image sources do not provide measured volume percentages, the volumetric accuracy of these manual results cannot be determined.

Additionally, one JPEG contained an invalid orientation metadata value. MATLAB displayed a warning but successfully opened the image.

Real-World Test Image Sources

All seven images were obtained from Wikimedia Commons:

1. Shaded Bottle Image
2. Labeled PET Bottle
3. Bottle Hanging Above a Street
4. Transparent Water Bottle
5. Bottle Containing Residual Water
6. Black-Capped Water Bottle
7. Bottle on a Glass Surface

Summary

The Water Bottle Fill Level Estimator is a MATLAB desktop application designed to estimate the amount of water inside a bottle using image processing techniques.

Its main capabilities include automatic bottle boundary detection, water-level estimation, approximate volume calculation, visual water-level indication, and manual correction tools.

The application runs entirely offline and requires no Python installation or additional MATLAB toolboxes.

Although the system achieved accurate results on synthetic test images, automatic detection was unsuccessful on all seven real-world photographs tested. Manual selection provides an alternative method for determining the height-based fill percentage when automatic detection fails.

Further improvements to bottle segmentation, water-surface detection, lighting robustness, and perspective handling would be necessary to achieve reliable performance on real-world images.