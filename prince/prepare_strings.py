file_path = "C:\\Users\\johna\\Downloads\\enemies.csv"

with open(file_path, "r") as file:
    file.readline()
    file.readline()
    lines = file.readlines()
    output = ""
    for line in lines:

        split = line.split(",")

        name = split[1]
        c = 0
        while c < len(name):
            char = name[c]
            if char.lower() != char:
                name = name[:c] + "^" + name[c:]
                c += 1
            c += 1

        element = split[2][0]

        level = split[3]

        enemy = '{n="' + name + '",e="' + element + '",l=' + level + '},'

        print(enemy)
        output += enemy

    print(output)
