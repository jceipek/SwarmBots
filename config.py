import serial

class BTConfigurer:
    def __init__(self, bdRate=9600):
        self._ser = serial.Serial('/dev/cu.Lassie-SPP',bdRate,timeout=10)
        #self.write('$$$')
        #self.write('D')
        #self.write('---')
        #print self.read()

    def write(self, command):
        self._ser.write(command)

    def performCommand(self, cmd, val):
        self.write(cmd+','+str(val))

    def read(self):
        return self._ser.readlines()

    def getInfo(self):
        self.write('D,')
        print self.read()
        self.write('E,')
        print self.read()

    def close(self):
        self.write('---')
        self._ser.close()

bt = BTConfigurer(bdRate=115200)
#bt.getInfo()
#bt.close()