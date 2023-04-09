import mysql.connector
from mysql.connector.cursor import MySQLCursor

try:
    import cx_Oracle
except ModuleNotFoundError:
    pass


class DbConnector:
    def __init__(self, username, password):
        self.username = username
        self.password = password

    def connect(self):
        raise NotImplementedError


class OracleConnector(DbConnector):
    def __init__(self, username, password):
        super(OracleConnector, self).__init__(username, password)

    def connect(self):
        login = f'{self.username}/{self.password}@artemis.vsnet.gmu.edu:1521/vse18c.vsnet.gmu.edu'
        print('Connecting...')
        conn = cx_Oracle.connect(login)
        print('Connection complete\n')
        return conn


class MySqlConnector(DbConnector):
    def __init__(self, username, password):
        super(MySqlConnector, self).__init__(username, password)

    def connect(self):
        print('Connecting...')
        conn = mysql.connector.connect(host="localhost", user=self.username, passwd=self.password)
        print('Connection complete\n')
        return conn
