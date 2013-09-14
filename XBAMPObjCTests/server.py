from twisted.protocols.amp import AMP, Command, Unicode
from twisted.internet import protocol
import random
import string


class SendMessage(Command):
    arguments = [('message', Unicode())]
    response = []


class ChatProtocol(AMP):
    @SendMessage.responder
    def sendMessage(self, message):
        m = "<{}> {}".format(self.name, message)
        for c in self.factory.clients:
            c.callRemote(SendMessage, message=m)
        return {}

    def connectionMade(self):
        self.name = u''.join(random.choice(string.ascii_letters) for x in range(8))
        self.factory.clients.append(self)
        m = "<<{} has joined the chat>>".format(self.name)
        for c in self.factory.clients:
            c.callRemote(SendMessage, message=m)

    def connectionLost(self, reason):
        if self in self.factory.clients:
            self.factory.clients.remove(self)
        m = "<<{} has left>>".format(reason)
        for c in self.factory.clients:
            c.callRemote(SendMessage, message=m)


class ChatFactory(protocol.ServerFactory):
    protocol = ChatProtocol
    def __init__(self):
        self.clients = []
