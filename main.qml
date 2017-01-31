import QtQuick 2.5
import QtQuick.Controls 1.4
import  QtQuick.LocalStorage 2.0
ApplicationWindow {
    //Insert To Database
    function insertList(str,model){
        //OPEN DB
        var db = LocalStorage.openDatabaseSync("simpleDB","1.0","To store the list",10000);
        //DO QUERYS ON DATABASE
        db.transaction(
                      //CALLBACK FUNCTION TO DO OPS ON tx (DB)
                      function(tx) {
                          tx.executeSql("CREATE TABLE IF NOT EXISTS storage(task TEXT)");
                          //Make sure same  task aleardy doesn't exist
                          var already = tx.executeSql("SELECT * FROM storage WHERE TASK LIKE  '"+str+"'");
                          if(already.rows.length != 0){
                                
                          }
                          else{
                              var result = tx.executeSql("INSERT INTO storage VALUES('"+str+"')");
                              if(result.rowsAffected == 1){
                                  //UPDATE SCREEN
                                  model.append({value:str});
                              }
                              else{
                                  //IF NOT INSTERTD

                              }
                          }
                       }
         );
    }
    //INTIALIZATION STEP : Load From DataBase when app startup
    function firstLoad(model){
        var db = LocalStorage.openDatabaseSync("simpleDB","1.0","To store the list",10000);
        //DO QUERYS ON DATABASE
        db.transaction(
                      //CALLBACK FUNCTION TO DO OPS ON tx (DB)
                      function(tx) {
                            var result = tx.executeSql("SELECT * FROM storage");
                            for(var i= 0 ;i<result.rows.length;i++){
                                model.append({value:result.rows.item(i).task});
                            }
                      }
        );
    }
    //ON CLOSE  Button click item is removed from the model and database
    function deleteFunc(task,model,index){
        //OPEN DB
        var db = LocalStorage.openDatabaseSync("simpleDB","1.0","To store the list",10000);
        //DO QUERYS ON DATABASE
        db.transaction(
                      //CALLBACK FUNCTION TO DO OPS ON tx (DB)
                      function(tx) {
                          tx.executeSql("DELETE FROM storage WHERE task LIKE '"+task+"'");
                          model.remove(index);
                      }
         );
    }
    //UI PART
    visible: true
    width: 360
    height: 520
    ListModel{
        id: listmodel
    }
    //COLUMN LAYOUT 1)TEXT FIELD 2)MODEL
    Column{
        anchors.fill: parent
        Rectangle{
            height: 35
            width: parent.width
            TextArea{
                id :textarea
                anchors.fill: parent
                textColor: "green"
                Keys.onReturnPressed: {
                    insertList(textarea.text,listmodel);
                }
                focus: true
            }
        }
        //Second Rectangle
        Rectangle{
            height: parent.height - 40
            width:  parent.width
            ListView{
                id : listviews
                anchors.fill:  parent
                anchors.margins: 10
                model  : listmodel
                clip : true
                delegate: viewdel
                spacing : 4
                currentIndex: 1
                //Green Box
                Component{
                    id : viewdel
                        Rectangle{
                            width: parent.width
                            height :40
                            //Green Box having col layout with 2 rows
                            Row{
                                  width: parent.width
                                  height :40
                                  //Text from db
                                  Rectangle{
                                      width: parent.width*3/4
                                      height :40
                                      color:  "green"
                                      focus: true
                                       Text {
                                              id: name
                                              x:10
                                              anchors.verticalCenter: parent.verticalCenter
                                              color: "white"
                                              text: qsTr(value)
                                      }
                                  }
                                  //Close
                                  Rectangle{
                                       width: parent.width*1/4
                                       height: 40
                                       color: "green"
                                       Image {
                                           height:30
                                           width:30
                                           source: "qrc:/close.png"
                                           anchors.centerIn: parent
                                           MouseArea{
                                               anchors.fill: parent
                                               onClicked: {
                                                   listviews.currentIndex=index
                                                   deleteFunc(name.text,listmodel,listviews.currentIndex)
                                               }
                                           }
                                       }
                                  }

                            }

                       }
                }
            }
        }
     }
    //LOADS FROM DATABSE ON STARTUP
    Component.onCompleted: {
        firstLoad(listmodel);
    }
}
