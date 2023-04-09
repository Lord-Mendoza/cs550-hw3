import sys
import mysql.connector
from mysql.connector.cursor import MySQLCursor
from mysql.connector import errorcode

try:
    import cx_Oracle
except ModuleNotFoundError:
    pass


class Executor:
    def __init__(self, conn, verbose=False):
        self.conn = conn
        self.verbose = verbose

    def execute(self, filepath, commit):
        raise NotImplementedError


class OracleExecutor(Executor):
    def execute(self, filepath, commit=True):
        conn = self.conn
        cursor = conn.cursor()

        with open(filepath) as f:
            file = f.read()

        for line in file.split(';'):
            line = line.strip()

            # Skip empty command
            if line == '':
                continue

            try:
                cursor.execute(line)
            except Exception as exception:
                self.handle_exception(exception, line)

        if commit:
            conn.commit()

    def handle_exception(self, exception, line):
        """ Handle exception while executing a line.

            Raises all errors except when error code equals 942 when
            the command is a DROP statement.

        Args:
            exception: Exception raised.
            line: Current line.

        """
        error, = exception.args
        if line == '':  # Empty line
            pass
        else:
            if self.verbose:
                print(f'{"-" * 70}\n{line}\n{"-" * 70}')

            if not isinstance(exception, cx_Oracle.DatabaseError):
                raise exception
            elif error.code == 942 and 'drop' in line.lower():  # 942 should only occur in drop command
                pass
            else:
                raise exception


class MySqlExecutor(Executor):
    def execute(self, filepath, commit=True):
        conn = self.conn
        cursor = conn.cursor(buffered=True)

        with open(filepath) as f:
            file = f.read()

        for block in file.split(';'):
            block = block.strip()

            # Skip empty command
            if block == '':
                continue

            # Remove comment from lines
            lines = block.split('\n')
            block = '\n'.join([i for i in lines if not (i.strip().startswith('--') or i == '')])

            try:
                cursor.execute(block)
            except mysql.connector.Error as exception:
                self._handle_exception(exception, block)

        if commit:
            conn.commit()

    @staticmethod
    def _handle_exception(exception, block):
        # Allow unknown table for drop command
        if exception.errno == errorcode.ER_BAD_TABLE_ERROR and 'drop' in block:
            return

        print(f'{"-"*70}\n>>> EXCEPTION OCCURRED FOR COMMAND :-\n{block}')
        print(f'\n>>> EXCEPTION MESSAGE :-\n{exception}')
        print('\n\nEXIT WITHOUT COMPLETING !')

        sys.exit(-1)
