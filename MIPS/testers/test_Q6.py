def f(x):
    if x <= 1:
        return 1
    return f((x + 1) / 3) + f((x + 1) / 4)

print(f(float(input())))
