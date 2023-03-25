def f(n):
    if n <= 1:
        return 2
    return n * f(n - 1) + 1


n = int(input('n: '))
f_n = f(n)
print(f_n)
print(hex(f_n))
