#mocs train controller
# front motor orange - lined up with gpio15
# front motor yellow - lined up with gpio13
# back motor yellow - lined up with gpio11
# back motor orange - lined up with last slot
import ble_uart
import bluetooth
import time
from machine import Pin, PWM

is_forward = True
forward_speed = 5000
reverse_speed = 65000

def forward():
    global forward_speed
    global is_forward
    is_forward = True
    pin14.off()
    forward_speed = 5000
    front.duty_u16(forward_speed)
    pin10.off()
    back.duty_u16(forward_speed)
    
def reverse():
    global reverse_speed
    global is_forward
    is_forward = False
    pin14.on()
    pin10.on()
    reverse_speed = 65000
    front.duty_u16(reverse_speed)
    back.duty_u16(reverse_speed)
    
def increase_speed():
    global forward_speed
    global reverse_speed
    print("increase speed")
    print(is_forward)
    if is_forward:
        forward_speed += 2500
        front.duty_u16(forward_speed)
        back.duty_u16(forward_speed)
    else:
        reverse_speed = reverse_speed - 2500
        front.duty_u16(reverse_speed)
        back.duty_u16(reverse_speed)

def decrease_speed():
    global forward_speed
    global reverse_speed
    if is_forward:
        forward_speed = forward_speed - 2500
        front.duty_u16(forward_speed)
        back.duty_u16(forward_speed)
    else:
        reverse_speed = reverse_speed + 2500
        front.duty_u16(reverse_speed)
        back.duty_u16(reverse_speed)
    
def stop():
    global forward_speed
    global reverse_speed
    print(is_forward)
    if is_forward:
        forward_speed = 5000
        front.duty_u16(forward_speed)
        back.duty_u16(forward_speed)
    else:
        reverse_speed = 65000
        front.duty_u16(reverse_speed)
        back.duty_u16(reverse_speed)

def print_handler():
    c = uart.read()
    print(c)
    if c == b'forward\r\n': forward()
    elif c == b'reverse\r\n': reverse()
    elif c == b'+\r\n': increase_speed()
    elif c == b'-\r\n': decrease_speed()
    elif c == b'stop\r\n': stop()

ble = bluetooth.BLE()
uart = ble_uart.Ble_uart(ble, on_rx=print_handler, name="mocs train")

pin14 = Pin(14, Pin.OUT)
pin15 = Pin(15, Pin.OUT)
pin14.off()
front = PWM(pin15)
front.freq(1000)
front.duty_u16(5000)

pin10 = Pin(10, Pin.OUT)
pin11 = Pin(11, Pin.OUT)
pin10.off()
back = PWM(pin11)
back.freq(1000)
back.duty_u16(5000)

forward()

while True:
    #uart.write("hello\n")
    time.sleep(1)
