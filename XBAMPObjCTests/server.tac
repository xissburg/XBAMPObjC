from server import ChatFactory
from twisted.application import internet, service

application = service.Application('chat')
internet.TCPServer(25683, ChatFactory()).setServiceParent(service.IServiceCollection(application))
