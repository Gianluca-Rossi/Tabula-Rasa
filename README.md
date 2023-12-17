# Tabula Rasa
##### WARNING: You must have a jailbroken device
### !!! Messy code, unrefined UI, WIP !!!

![Cache deletion demo](https://github.com/Gianluca-Rossi/Tabula-Rasa/assets/23359318/5e5d5427-67d2-4cc4-8116-ddb803be3eee)
![File browser demo](https://github.com/Gianluca-Rossi/Tabula-Rasa/assets/23359318/b1754375-5b2a-46a7-8121-6ad2f39937f5)




### 1) Install the app via Xcode 14 or earlier

### 2) Using a file browser app such as Filza, copy the folder *Tabula Rasa.app* from */containers/Bundle/Application/Tabula Rasa/* in */Applications/*

### 3) Open a terminal app tweak such as NewTerm3, enter the following command:
```
su
```
##### Now type the root user password (the default password is "*alpine*") and press enter, then run the following commands:

```
cd ../..
```

```
chown root:wheel "./Applications/Tabula Rasa.app/Tabula Rasa"
```

```
chmod 6755 "./Applications/Tabula Rasa.app/Tabula Rasa"
```

### 4) Delete the Tabula Rasa app installed via Xcode
##### TIP: if the Tabula Rasa app icon doesn't show up on the home screen, long press any app icon to show its quick actions menu and then dismiss it

### 5) Run the following command in NewTerm3:

```
uicache && sbreload
```
