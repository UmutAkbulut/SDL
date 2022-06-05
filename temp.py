import pandas as pd
import numpy as np
from flask import Flask
from flask import jsonify
import json
from flask import request
import mysql.connector
import datetime as dt


app=Flask(__name__)
app.config['JSON_SORT_KEYS']=False



mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="Katamaran",
  database="smartdoorlock"
)

@app.route("/registermechanism")
def registermechanism():
    try:
        mechanism_id = request.args.get('mechanismid')
        phone = request.args.get('phone')
       
        sql = "INSERT INTO mechanisms(mechanism_id,user_phone) VALUES (%s, %s)"
        val = (mechanism_id, phone)
       
   

        mycursor = mydb.cursor()
        mycursor.execute(sql, val)
       
        mydb.commit()
        mycursor.close()

           
        info = {
               
            "mechanism_id" : mechanism_id,
            "phone" : phone,
            "status" : True
               
            }
           
       
        record(phone, mechanism_id, "Mechanism Matched!")
        return jsonify(info)
   
    except:
       
        info = {
           
            "mechanism_id" : mechanism_id,
            "phone" : phone,
            "status" : False
           
            }
       
        return jsonify(info)


@app.route("/register")
def register():
    try:
        name = request.args.get('name')
        surname = request.args.get('surname')
        phone = request.args.get('phone')
        password = request.args.get('password')
       
       
        if(len(phone) != 11):
            return "Phone number is invalid!"

   

        mycursor = mydb.cursor()
        mycursor.execute("SELECT COUNT(*) AS COUNT FROM users WHERE phone=" + phone)

        myresult = mycursor.fetchone()
        mycursor.close()

        print(myresult[0])
       
        if myresult[0] == 1:
            info = {
               
                "name" : name,
                "surname" : surname,
                "phone" : phone,
                "password" : password,
                "status" : False
               
                }
           
            return jsonify(info)

        else:
            sql = "INSERT INTO users (name, surname, phone, password) VALUES (%s, %s, %s, %s)"
            val = (name,  surname, phone, password)
       

            mycursor.execute(sql, val)
       
            mydb.commit()
            mycursor.close()

            info = {
               
                "name" : name,
                "surname" : surname,
                "phone" : phone,
                "password" : password,
                "status" : True
               
                }
           
            return jsonify(info)
   
    except:
       
        info = {
           
            "name" : name,
            "surname" : surname,
            "phone" : phone,
            "password" : password,
            "status" : False
           
            }
       
        return jsonify(info)
   

def record(user_phone, mechanism_id, action):
    try:
       

       
        date = dt.datetime.now()
       
   
       
        mycursor = mydb.cursor()
        sql = "INSERT INTO entry_records (mechanism_id, user_phone, action, date) VALUES (%s, %s, %s, %s)"
        val = (mechanism_id,  user_phone, action, date)

        mycursor.execute(sql, val)
   
        mydb.commit()
        mycursor.close()

        info = {
               
                "mechanism_id" : mechanism_id,
                "user_phone" : user_phone,
                "action" : action,
                "date" : date,

                "status" : True,
               
               
                }
           
        return jsonify(info)
       
    except Exception as e:
        print(e)
        return "Log Creation Error!"


@app.route("/changeLockStatus")
def changeLockStatus():

    mycursor = mydb.cursor()
    mechanism_id = request.args.get('mechanism_id')
    user_phone = request.args.get('user_phone')
    action = request.args.get('action')


   
    if(action == "lock"):
        status = 1
        record(user_phone, mechanism_id, "Mechanism Locked!")
    else:
        status = 0
        record(user_phone, mechanism_id, "Mechanism Unlocked!")

   
    sql = "UPDATE mechanisms SET lock_status = %s WHERE mechanism_id = %s"
    val = (status, mechanism_id)

    mycursor.execute(sql, val)

    mydb.commit()
    mycursor.close()


   

    info = {
           
            "mechanism_id" : mechanism_id,
            "action" : action,

            "status" : True,
           
           
            }
       
    return jsonify(info)
       
@app.route("/changeAutoLockStatus")
def changeAutoLockStatus():


    mycursor = mydb.cursor()
    mechanism_id = request.args.get('mechanism_id')
    user_phone = request.args.get('user_phone')
    action = request.args.get('action')


   
    if(action == "on"):
        status = 1
        record(user_phone, mechanism_id, "Mechanism Autolock Mode Opened!")
    else:
        status = 0
        record(user_phone, mechanism_id, "Mechanism Autolock Mode Closed!")

   
    sql = "UPDATE mechanisms SET auto_lock = %s WHERE mechanism_id = %s"
    val = (status, mechanism_id)

    mycursor.execute(sql, val)

    mydb.commit()
    mycursor.close()

   

    info = {
           
            "mechanism_id" : mechanism_id,
            "action" : action,

            "status" : True,
           
           
            }
       
    return jsonify(info)
       
   
@app.route("/getMechanisms")
def getMechanism():
    try:
        user_phone = request.args.get('user_phone')
   

        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM mechanisms WHERE user_phone="+ user_phone )
        row_headers=[x[0] for x in mycursor.description]
        rv = mycursor.fetchall()
        mycursor.close()

        json_data=[]
        for result in rv:
           json_data.append(dict(zip(row_headers,result)))
        return json.dumps(json_data)
    except Exception as e:
        print(e)
        return "Mechanism Get Error!"

@app.route("/login")
def login():
    try:
        phone = request.args.get('phone')
        password = request.args.get('password')
   
        mycursor = mydb.cursor()
        mycursor.execute("SELECT COUNT(*) AS COUNT FROM users WHERE phone=" + phone + " AND password=" + password)

        myresult = mycursor.fetchone()
        mycursor.close()

        if myresult[0] == 1:
           
            info = {
               
                "phone" : phone,
                "password" : password,
                "status" : True,
               
               
                }
           
            return jsonify(info)
       
        info = {
           
            "phone" : phone,
            "password" : password,
            "status" : False,
           
           
            }
       

        return jsonify(info)
    except Exception as e:
        print(e)
        return "Login Error!"
   
app.run()


