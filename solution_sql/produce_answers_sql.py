import os
import sys
import json
from natsort import natsorted

from src.sql.main import MySqlGenerator
from credentials import username, password

if __name__ == '__main__':
    if len(sys.argv) == 1:
        path_to_student_sql = 'queries.sql'
    else:
        path_to_student_sql = sys.argv[1]

    answer_save_path = os.path.join('answers.json')
    # dbs = {}
    db_list = []
    for filename in natsorted(os.listdir(os.path.join("..", "testDBs"))):
        if filename.startswith('db') and filename.endswith('.json'):
            file_path = os.path.join('testDBs', filename)
            print(f'Found db file: {file_path}')
            with open(os.path.join("..", file_path), 'r') as f:
                db = json.load(f)
            # db_name = filename.split('.json')[0]
            # dbs[db_name] = db
            db_list.append(db)
    dbs = {f'db{i + 1}': db for i, db in enumerate(db_list)}
    answer_generator = MySqlGenerator(username=username, password=password,
                                      create_file=os.path.join('config','create_empty_tables.sql'))
    answers = {}

    with open(os.path.join('..','config', 'view_names.json'), 'r') as f:
        views = json.load(f)['views']

    # Generate query for each db
    # for db_name, db in dbs.items():
    for db_name, db in dbs.items():
        print('-' * 70)
        print(f'Creating answer for db: {db_name}')
        print('-' * 70)
        answers[db_name] = answer_generator.generate_answers(db=db, query=path_to_student_sql,
                                                             views=views)
    # Save output
    print('\n\n')
    print('-*' * 35)
    print(f'Saving answers to {answer_save_path}')
    # print(f'Saving these answers {answers}')
    with open(answer_save_path, 'w') as f:
        json.dump(answers, f)
    print(f'Output saved in {answer_save_path}')
    print('-*' * 35)
