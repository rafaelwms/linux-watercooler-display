# The display takes an 8-byte payload:
# [TEMP, 0x1c, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00]
# Where
# - TEMP is an int (0-255) representing the CPU temperature
# - The second byte appears to be the GPU temp. It doesn't seem to affect the display
# - The fifth byte is unknown. I tried different values, but nothing seemed to happen

import usb.core
import psutil
import time

VENDOR_ID = 0xaa88
PRODUCT_ID = 0x8666

# IN_ENDPOINT = 0x82
TEMP_ENDPOINT = 0x01

dev = usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)

assert dev is not None

if dev.is_kernel_driver_active(0):
    dev.detach_kernel_driver(0)

# Reset to make sure the display will respond
dev.reset()

# Enable device
dev.set_configuration()

# Get an endpoint instance
cfg = dev.get_active_configuration()
intf = cfg[(0,0)]

# Listar todos os endpoints disponíveis para depuração
print("Endpoints disponíveis:")
for endpoint in intf.endpoints():
    print(f"  Endereço: 0x{endpoint.bEndpointAddress:02x}, Atributos: 0x{endpoint.bmAttributes:02x}, Direção: {'IN' if endpoint.bEndpointAddress & 0x80 else 'OUT'}")

ep = usb.util.find_descriptor(
    intf,
    custom_match=lambda e: e.bEndpointAddress == TEMP_ENDPOINT
)
if ep is None:
    raise RuntimeError(f"Endpoint com endereço 0x{TEMP_ENDPOINT:02x} não encontrado.")

def set_temp(tmp: int):
    ep.write([tmp, 0x1c, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00])

# The display doesn't change the temperature instantly
# It performs a smooth transition at the rate of (CURRENT_TEMP - TARGET_TEMP) / 5
# We send the temperature 5 times to make the update faster
def set_temp_force(tmp: int):
    for _ in range(5):
        set_temp(tmp)
        time.sleep(0.05)

while True:
    temps = psutil.sensors_temperatures()
    set_temp(int(temps['coretemp'][1].current))
    time.sleep(1)