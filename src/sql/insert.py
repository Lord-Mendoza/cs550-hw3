import json
import mysql.connector
from mysql.connector.cursor import MySQLCursor

try:
    import cx_Oracle
except ModuleNotFoundError:
    pass


class DbInserter:
    def __init__(self, conn, verbose=False):
        self.conn = conn
        self.verbose = verbose

    def insert(self, filepath, table_names=None, commit=True):
        raise NotImplementedError


class OracleInserter(DbInserter):

    def insert(self, filepath, table_names=None, commit=True):
        """

        Args:
            filepath:
            table_names:
            commit:

        Notes:
            The json file should have the structure:
            {
                "tables": {
                    "table1": [
                        {"att1": val1, "att2": val2, ... },  # Tuple1
                        {"att1": val1, "att2": val2, ... },  # Tuple2
                        ... ]
                    }
            }
        """
        conn = self.conn
        cursor = conn.cursor()

        # Load json file
        with open(filepath, 'r') as f:
            data = json.load(f)

        tables_dict = data["tables"]

        # Insert table names based on order passed
        if table_names is None:
            table_names = list(tables_dict.keys())

        for table_name in table_names:

            rows = tables_dict[table_name]  # List of dictionary
            if len(rows) == 0:    # Skip if any no values
                continue

            # List of row tuples ordered by the column name
            row_tuple_list = []

            for row_dict in rows:
                row_tuple = []

                for col_name in sorted(row_dict.keys()):
                    row_tuple.append(row_dict[col_name])
                row_tuple_list.append(tuple(row_tuple))

            # Column names are based on last tuple which should be same for all
            col_names = ','.join(sorted(row_dict.keys()))

            # Make the command to execute ready
            command = f"INSERT INTO {table_name} ({col_names}) VALUES ("
            for i in range(len(row_tuple)):
                command += ":" + str(i + 1) + ","
            command = command[:-1] + ")"
            cursor.bindarraysize = len(row_tuple_list)
            try:
                cursor.executemany(command, row_tuple_list)
            except cx_Oracle.IntegrityError as exc:
                error, = exc.args
                print('-' * 70)
                print(error.code, error.message)
                print(command, row_tuple_list)

        if commit:
            conn.commit()


class MySqlInserter(DbInserter):
    def insert(self, data, table_names=None, commit=True):
        conn = self.conn
        cursor = conn.cursor(buffered=True)

        tables_dict = data["tables"]

        # Insert table names based on order passed
        if table_names is None:
            table_names = list(tables_dict.keys())

        for table_name in table_names:
            rows = tables_dict[table_name]  # List of dictionary
            # Skip if any no values
            if len(rows) == 0:
                continue
            columns = [i for i in rows[0]]
            col_str = ','.join(sorted(rows[0].keys()))

            command1 = f'INSERT INTO {table_name}('
            command2 = ' VALUES ('
            for c in columns:
                command1 += f'{c},'
                command2 += f'%({c})s,'
            command1 = command1[:-1] + ')'
            command2 = command2[:-1] + ');'
            command = command1 + command2

            for row in rows:
                cursor.execute(command, row)

        if commit:
            conn.commit()
