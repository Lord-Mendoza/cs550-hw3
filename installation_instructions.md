# Windows

### 1. Python Installation
--> Requires python 3.8  
--> Go to python.org/downloads 
--> Scroll down to 3.8.10 which has installer package for windows

### 2. Visual Studio to use MySQL
Link to install https://docs.microsoft.com/en-us/visualstudio/releases/2019/   
--> Download Community Edition  
--> During install, select option for *python development*

### 3. MySQL
Link to install: https://www.mysql.com/downloads/  
--> Go to **MySQL Community (GPL) Downloads** link towards bottom of page  
--> Select **MySQL Installer for Windows**
--> Run mysql-installer-web-community-8.0.28.1.msi  

--> Generally use most defaults and do not need configure router or samples  
--> Be sure to write down the username and password, it requires an 8 digit password. You must include this in your credentials.py file.  

### 4. Go to project folder
--> Open command-prompt and go to the project folder using the change directory command.  
--> The project folder contains setup.py and is the root directory for the solution (one level above solution_algebra, solution_calculus and solution_sql)  

### 5. Creating Virtual Environment (Optional)
Run the following command to create a virtual environment. 
This will create a new folder named **env**  in the project folder.  
```
   python -m venv env
```
Then, run the following command to **activate** the virtual environment.  
```
   env/Scripts/activate.bat
``` 
*Note: If you create the virtual environment, you need to activate the virtual environment each time you open the command prompt before running your queries. 
However, this is considered a good programming practice.*

### 6. Project Setup
Following the previous step directly, make sure you are in the project folder in the command line.  
Run the following command in the same.
```
   pip install -e .
```
*Note: Make sure to include the dot(.) at the end of the command.*

### 7. Credentials
--> Set your username and password provided in `credentials.py`.  
--> For example, if you set the password as dbpassword, your `credentials.py` file should look like 
```
    username = 'root'
    password = 'dbpassword'
```
--------------------------------------------------------------------------------------------

# Mac

### 1. Python Installation
Requires python 3.8  
Tutorial for python installation:
https://realpython.com/installing-python/ 

### 2. MySQL
Install MySQL Server community version. Go to URL: https://dev.mysql.com/downloads/mysql/  
--> Select Operating System  
--> Select OS Version (Select macOS 11 (ARM, 64-bit) for M1 processor)  
--> Download the necessary package (DMG archive for macOS)  
--> Install the downloaded package  
--> Remember the password for root user, it requires an 8 digit password. You must include this in your credentials.py file.  

### 3. Code Editor (Optional)
--> Install/Use your preferred code editor. ATOM is suggested for better json visualization.

**More steps below which are the same for Windows/Mac/Ubuntu**

--------------------------------------------------------------------------------------------
# Ubuntu

### 1. Python Installation
Requires python 3.8  
Tutorial for python installation: https://realpython.com/installing-python/  
Ubuntu usually comes with python3 by default.

### 2. MySQL
sudo apt update
sudo apt install mysql-server

### 3. Code Editor (Optional)
--> Install/Use your preferred code editor. ATOM is suggested for better json visualization.

**More steps below which are the same for Mac/Ubuntu**

--------------------------------------------------------------------------------------------

## Further steps for ALL

### 4. Virtual Environment
Go to project folder in your command-prompt/bash using the change directory command.  
The project folder is the one that has the file **setup.py** in it.  
Run the following command one line at a time.
```
   python -m venv env
   source env/bin/activate
```

### 5. Project Setup
Following the previous step directly, make sure you are in the project folder in the command line.
Run the following command in the same.
```
   pip install -e .
```


### 6. Credentials
Open `mysql` from command line using
```
    mysql -u root
```
Then, inside mysql command prompt, type the following lines of code one by one: 
```
USE mysql;  
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'password';  
GRANT ALL PRIVILEGES ON *.* TO 'user1'@'localhost';  
FLUSH PRIVILEGES;
exit;
```
--> Following the exact command above creates a username `user1` with password `password`.   
You can change it to your liking but make sure to update the credentials file accordingly.  
--> Set your username and password provided in `credentials.py`.  
If you used the exact same command as above, your `credentials.py` file should look like 
```
    username = 'user1'
    password = 'password'
```
