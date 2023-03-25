b = int(input('enter chars count: '))

l = [0, 1]
while l[-1] < b:
    l.append(l[-1] + l[-2])

s = set(l)
string_builder = []
for i in range(b - 1):
    if i in s:
        string_builder.append('X')
    else:
        string_builder.append('O')
string_builder.append('E')

expected_length = string_builder.count('O')
if not b - 1 in s:
    expected_length += 1

print('chars: ', ''.join(string_builder))
print('expected length: ', expected_length)
