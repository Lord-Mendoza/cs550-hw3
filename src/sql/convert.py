import decimal
import mysql.connector
from collections import OrderedDict


class QueryToJsonConverter:
    def __init__(self, conn):
        self.conn = conn

    def query_to_json(self, query):
        raise NotImplementedError


class MySqlQueryConverter(QueryToJsonConverter):

    def query_to_json(self, cursor):

        # name, type, display_size, internal_size, precision, scale, null_ok
        columns = OrderedDict()

        rows_dict_list = []

        for col_idx, desc in enumerate(cursor.description):
            col_type = desc[1]
            precision = desc[4]
            scale = desc[5]

            if col_type == mysql.connector.NUMBER:
                col_type = 'number'
            elif col_type == mysql.connector.STRING:
                col_type = 'string'

            columns[col_idx] = {
                'name': desc[0],
                'type': col_type,
                'precision': precision,
                'scale': scale,
                'null_ok': desc[6]
            }

        result = cursor.fetchall()

        for row in result:
            row_dict = {}

            for col_idx, col in columns.items():
                col_name = col['name']
                if isinstance(row[col_idx], decimal.Decimal):
                    value = row[col_idx]
                    if int(value) == float(value):
                        row_dict[col_name] = int(row[col_idx])
                    else:
                        row_dict[col_name] = float(row[col_idx])

                else:
                    row_dict[col_name] = row[col_idx]
            rows_dict_list.append(row_dict)

        return rows_dict_list

