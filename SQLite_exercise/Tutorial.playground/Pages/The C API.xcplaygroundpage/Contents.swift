import SQLite
import XCPlayground
import Foundation

destroyPart1Database()

/*: 

# Getting Started

The first thing to do is set your playground to run manually rather than automatically. This will help ensure that your SQL commands run when you intend them to. At the bottom of the playground click and hold the Play button until the dropdown menu appears. Choose "Manually Run". 

You will also notice a `destroyPart1Database()` call at the top of this page. You can safely ignore this, the database file used is destroyed each time the playground is run to ensure all statements execute successfully as you iterate through the tutorial.

Secondly, this Playground will need to write SQLite database files to your file system. Create the directory `~/Documents/Shared Playground Data/SQLiteTutorial` by running the following command in Terminal.

`mkdir -p ~/Documents/Shared\ Playground\ Data/SQLiteTutorial`

*/

//: ## Open a Connection
func openDatabase() -> COpaquePointer {
    var db: COpaquePointer = nil
    if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(part1DbPath)")
        return db
    } else {
        print("Unable to open database. Verify that you create the directory described" + "in the Getting Started Section.")
        XCPlaygroundPage.currentPage.finishExecution()
    }
}
let db = openDatabase()


//: ## Create a Table
let createTableString = "CREATE TABLE Contact(" + "Id INT PRIMARY KEY NOT NULL," + "Name CHAR(255))"

func createTable(){
    var createTableStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
            print("Contact table created.")
        } else {
            print("Contact table could not be created.")
        }
    } else {
        print("CREATE TABLE statement could not be prepared.")
    }
    sqlite3_finalize(createTableStatement)
}
createTable()



//: ## Insert a Contact
let insertStatementString = "INSERT INTO Contact (Id,Name) VALUES (?,?);"
func insert() {
    var insertStatement: COpaquePointer = nil
    let names: [NSString] = ["Ray","Chirs","Martha","Danielle"]
    //编译语句
    if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
        //遍历数组
        for (index,name) in names.enumerate() {
            
        let id = Int32(index + 1)
        //将Int型的值绑定到插入语句中
        sqlite3_bind_int(insertStatement, 1, id)
        //将文本数值绑定到插入语句中
        sqlite3_bind_text(insertStatement, 2, name.UTF8String, -1, nil)
        //执行语句
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Successfully inserted row.")
        } else {
            print("Could not insert row.")
        }
          //重置插入语句
          sqlite3_reset(insertStatement)
      }
    } else {
        print("INSERT Statement could not be prepared.")
    }
    //结束语句
    sqlite3_finalize(insertStatement)
}

insert()

//: ## Querying
let queryStatementString = "SELECT * FROM Contact;"

func query(){
    var queryStatement: COpaquePointer = nil
    
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        
         while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            
            let id = sqlite3_column_int(queryStatement, 0)
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String.fromCString(UnsafePointer<CChar>(queryResultCol1))!
            
            print("Query Result:")
            print("\(id) | \(name)")
        }
    } else {
        print("SELECT statement could not be prepared")
    }
    sqlite3_finalize(queryStatement)
}
query()


//: ## Update
let updateStatementString = "UPDATE Contact SET name = 'Chris' WHERE Id = 1;"
func update(){
    var updateStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("Successfully updated row.")
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared.")
    }
    sqlite3_finalize(updateStatement)
}
update()
query()

//: ## Delete
let deleteStatementString = "DELETE FROM Contact WHERE Id = 1;"
func delete(){
    var deleteStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted row.")
        } else {
            print("Could not delete row.")
        }
    } else {
        print("DELETE Statement could not be prepared.")
    }
    sqlite3_finalize(deleteStatement)
}
delete()
query()
//: ## Errors
let malformedQueryString = "SELECT Stuff from things WHERE Whatever;"
func prepareMalFormedQuery(){
    var malformedStatement: COpaquePointer = nil
    if sqlite3_prepare_v2(db, malformedQueryString, -1, &malformedStatement, nil) == SQLITE_OK {
        print("This should not have happened.")
    } else {
        let errorMessage = String.fromCString(sqlite3_errmsg(db))!
        print("Query could not be prepared! \(errorMessage)")
    }
    sqlite3_finalize(malformedStatement)
}
prepareMalFormedQuery()


//: ## Close the database connection
sqlite3_close(db)


//: Continue to [Making It Swift](@next)
