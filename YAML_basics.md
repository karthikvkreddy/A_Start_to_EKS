# YAML Basics

## Yaml Syntax

### Extension
  yaml files are saved using .yml or .yaml extemsions
### commenting
   using #
   
    #This is YAML syntx for commenting
### key value pairs
  ```
  name: "karthik"       #string
  age: 23               #intiger
  male: true            #boolean
  birthday: 1998-06-16 14:33:22   # it follows ISO 8601 standards
  falws: null            #null
  ```
  
### creating objects
  above created key value pairs are put into object by intending.
  ```
  person:
    name: "karthik"       #string
    age: 23               #intiger
    male: true            #boolean
    birthday: 1998-06-16 14:33:22   # it follows ISO 8601 standards
    falws: null            #null
  ```
  
  here person is the object.
  
### creating list
  ```
  hoobies:
    - "cricket"
    - "footbal"
    - "art"
  
  # another way to create list
  hobbies: ["cricket","football","art"]
 ```
 ### creating list of object
 ```
friend:
  - name: "reddy"
    age: 20
  - name: "kiran"
    age: 21
    
 # another way to create list of objects
friends:
  - {name:"reddy",age=20}
  
 ## 1 more method
 friends:
   -
    name: "kiran"
    age: 21
```
### adding Description
```
description:
  This is the way to create description. In yaml file description is very important that describes about the program in details.
  
#If you want descrption in a line by line , ratther than in a single line , make use of > sysmbol
description: >
  This is the way to create description. 
  In yaml file description is very important 
  that describes about the program in details.

 # if you want to preserve the formating. make use of | symbol
 signature: |
  karthik
  intern
  reddykarthik958gmail.com
 ```
### anchor a value and access value
```
# we are achoring the value name using &
person:
  name: &name "karthik"       #string
  age: 23               #intiger
 
#accessing the value using *
id: *name
```
### type casting data types
```

  age: !!str 23         # integer to string "23"      
  heigh: !float 5       # integer to float  5.0

 ```
