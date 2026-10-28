import numpy as np
import matplotlib.pyplot as plt

input_file = "output_signal.txt"

width = 254
height = 254

data = []


with open(input_file, "r") as file:
    for line in file:
        row = [int(val) for val in line.strip().split() if val.isdigit()]
        data.append(row)

if len(data) != height or any(len(row) != width for row in data):
    raise ValueError("Dimenzije slike nisu 254x254!")

image_array = np.array(data, dtype=np.uint8)

plt.imsave("output_image.jpg", image_array, cmap='gray')

print("Slika uspešno sačuvana kao output_image.jpg.")