
string = input()

for character in string:
    print(hex(ord(character))[2:])

for i in range(8192 - len(string)):
    print("00")


