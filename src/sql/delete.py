
class DbDeleter:
    def __init__(self, conn, verbose=False):
        self.conn = conn
        self.verbose = verbose

    def delete(self):
        raise NotImplementedError


class OracleDeleter(DbDeleter):
    del_all_plsql = """
            BEGIN
               FOR cur_rec IN (SELECT object_name, object_type
                                 FROM user_objects
                                WHERE object_type IN
                                         ('TABLE',
                                          'VIEW',
                                          'PACKAGE',
                                          'PROCEDURE',
                                          'FUNCTION',
                                          'SEQUENCE',
                                          'SYNONYM',
                                          'PACKAGE BODY'
                                         ))
               LOOP
                  BEGIN
                     IF cur_rec.object_type = 'TABLE'
                     THEN
                        EXECUTE IMMEDIATE    'DROP '
                                          || cur_rec.object_type
                                          || ' "'
                                          || cur_rec.object_name
                                          || '" CASCADE CONSTRAINTS';
                     ELSE
                        EXECUTE IMMEDIATE    'DROP '
                                          || cur_rec.object_type
                                          || ' "'
                                          || cur_rec.object_name
                                          || '"';
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        DBMS_OUTPUT.put_line (   'FAILED: DROP '
                                              || cur_rec.object_type
                                              || ' "'
                                              || cur_rec.object_name
                                              || '"'
                                             );
                  END;
               END LOOP;
            END;
            """

    def delete(self):
        conn = self.conn
        cursor = conn.cursor()

        cursor.execute(self.del_all_plsql)
        if self.verbose:
            print(f'Deleted all tables.')


class MySqlDeleter(DbDeleter):
    def delete(self):
        conn = self.conn
        cursor = conn.cursor(buffered=True)
        cursor.execute('SELECT DATABASE();')
        for result in cursor:
            db_name = result[0]

        cursor.execute(f"DROP DATABASE {db_name};")
        cursor.execute(f"CREATE DATABASE {db_name};")
        cursor.execute(f"USE {db_name};")
        conn.commit()

        if self.verbose:
            print(f'Deleted all tables from database {db_name}')
