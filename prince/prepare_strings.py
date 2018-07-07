file_path = "enemies.csv"

with open(file_path, "r") as file:
    file.readline()
    file.readline()
    lines = file.readlines()
    output = ""
    for line in lines:

        split = line.split(",")

        id = split[1]

        name = split[2]
        c = 0
        while c < len(name):
            char = name[c]
            if char.lower() != char:
                name = name[:c] + "^" + name[c:]
                c += 1
            c += 1

        element = split[3][0]

        level = split[4]

        enemy = '{i=' + id + ',n="' + name + '",e="' + element + '",l=' + level + '},'

        print(enemy)
        output += enemy

    print("stats = {" + output + "}")
