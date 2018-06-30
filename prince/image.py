from PIL import Image
import numpy
import math

pallet = [
    (0, 0, 0),
    (29, 43, 83),
    (126, 37, 83),
    (0, 135, 81),
    (171, 82, 54),
    (95, 87, 79),
    (194, 195, 199),
    (255, 241, 232),
    (255, 0, 77),
    (255, 163, 0),
    (255, 236, 39),
    (0, 228, 54),
    (41, 173, 255),
    (131, 118, 156),
    (255, 119, 168),
    (255, 204, 170)
]

hex_pallet = [
    0xFF000000,
    0xFF532B1D,
    0xFF53257E,
    0xFF518700,
    0xFF3652AB,
    0xFF4F575F,
    0xFFC7C3C2,
    0xFFE8F1FF,
    0xFF4D00FF,
    0xFF00A3FF,
    0xFF27ECFF,
    0xFF36E400,
    0xFFFFAD29,
    0xFF9C7683,
    0xFFA877FF,
    0xFFAACCFF
]


def load_and_compress_images(sheets, outfilename):
    w = 128
    h = 128
    img = numpy.empty((w, h), numpy.uint32)
    img.shape = h, w
    img.fill(hex_pallet[0])

    offset = 0
    for sheet in sheets:
        infilename = sheet["file"]
        tw = sheet["tw"]
        th = sheet["th"]
        bw = sheet["bw"]
        layers = sheet["layers"]

        src_img = Image.open(infilename)
        src_img.load()
        src_npdata = numpy.asarray(src_img, dtype="int32")
        sh, sw = src_npdata.shape[0], src_npdata.shape[1]
        rows = int((sh - bw) / (th + bw))
        cols = int((sw - bw) / (tw + bw))

        l_cols = int(math.ceil(cols / layers))

        for r in range(rows):
            for c in range(l_cols):
                for y in range(th):
                    for x in range(tw):
                        pixel_pallet = 0

                        for l in range(layers):
                            if l + c * layers >= cols:
                                continue
                            sx = bw + x + l * (tw + bw) + c * (tw + bw) * layers
                            sy = bw + y + r * (th + bw)
                            src_color = src_npdata[sy, sx]
                            if src_color[0] == 0 and src_color[1] == 0 and src_color[2] == 0:
                                pixel_pallet += int(math.pow(2, l))

                        color = hex_pallet[pixel_pallet]
                        tx = x + c * tw
                        ty = y + r * th
                        img[ty, tx + offset] = color

        offset += l_cols * tw

    img = Image.frombuffer('RGBA', (w, h), img, 'raw', 'RGBA', 0, 1)
    img.save(outfilename)


def convert255x3to0xFFFFFFFF(sequence):
    value = 255 + sequence[2] * 256 + sequence[1] * 256 * 256 + sequence[0] * 256 * 256 * 256
    raw = hex(value)
    return raw


sheets = [
    {
        "file": "C:\\Users\\johna\\Desktop\\5x5.png",
        "tw": 5,
        "th": 5,
        "bw": 1,
        "layers": 4
    },
    {
        "file": "C:\\Users\\johna\\Desktop\\3x5.png",
        "tw": 3,
        "th": 5,
        "bw": 1,
        "layers": 4
    }
]

combined_path = "C:\\Users\\johna\\AppData\\Roaming\\pico-8\\carts\\combined.png"
load_and_compress_images(sheets, combined_path)
