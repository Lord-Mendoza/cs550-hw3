import os
import mysql.connector

from src.sql.connect import MySqlConnector
from src.sql.delete import MySqlDeleter
from src.sql.execute import MySqlExecutor
from src.sql.insert import MySqlInserter
from src.sql.convert import MySqlQueryConverter


class MySqlGenerator:
    def __init__(self, username, password, create_file, dbname='project'):
        self.username = username
        self.password = password
        self.dbname = dbname

        self.create_file = create_file
        self._init_modules()

    def _init_modules(self):
        self.connector = MySqlConnector(self.username, self.password)
        self.conn = self.connector.connect()

        # Select database to use
        print(f'Using Database: {self.dbname}')
        self.conn.cursor().execute(f'CREATE DATABASE IF NOT EXISTS {self.dbname};')
        self.conn.cursor().execute(f'USE {self.dbname};')
        self.conn.commit()

        self.deleter = MySqlDeleter(conn=self.conn)
        self.inserter = MySqlInserter(conn=self.conn)
        self.executor = MySqlExecutor(conn=self.conn)
        self.converter = MySqlQueryConverter(conn=self.conn)

    def _fill_db(self, db):
        self.deleter.delete()
        self.executor.execute(self.create_file)
        self.inserter.insert(data=db)

    def generate_answers(self, db, query, views):
        self._fill_db(db=db)
        self.executor.execute(query)
        answer_dict = {}

        for view in views:
            cursor = self.conn.cursor(buffered=True)
            try:
                cursor.execute(f'SELECT * FROM {view}')
            except mysql.connector.Error as err:
                print(f'{"-" * 70}\n>>> EXCEPTION OCCURRED FOR QUERY VIEW :-\n{view}')
                print(f'\n>>> EXCEPTION MESSAGE :-\n{err}')
                answer_dict[view] = None
                continue
            answer_dict[view] = self.converter.query_to_json(cursor)

        return answer_dict
