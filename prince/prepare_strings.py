file_path = "C:\\Users\\johna\\Downloads\\enemies.csv"

with open(file_path, "r") as file:
    file.readline()
    file.readline()
    lines = file.readlines()
    output = ""
    for line in lines:
        name = line.split(",")[1]
        c = 0
        while c < len(name):
            char = name[c]
            if char.lower() != char:
                name = name[:c] + "^" + name[c:]
                c += 1
            c += 1
        element = line.split(",")[2][0]
        enemy = '{n="' + name + '",e="' + element + '"},'
        print(enemy)
        output += enemy

    print(output)
