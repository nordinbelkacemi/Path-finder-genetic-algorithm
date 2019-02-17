from matplotlib import pyplot as plt
import csv

x = []
y = []
z = []

with open('performance.csv', newline='') as csvfile:
    data = csv.reader(csvfile, delimiter=',')
    for row in data:
        x.append(int(row[0]))
        y.append(float(row[1]))
        z.append(float(row[2]))

plt.plot(x, y)
plt.plot(x, z)
plt.title("Fitness plot")
plt.xlabel("Generation")
plt.ylabel("Total length")
plt.show()
