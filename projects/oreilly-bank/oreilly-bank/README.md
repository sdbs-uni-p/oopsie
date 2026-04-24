# oreilly-bank-example

## About

The bank example project from the book Database Programming with JDBC & Java, Second Edition by George Reese set up for
test the [Optional PreparedStatement Checker](https://github.com/eisop/opsc/).
The original source code can be found at https://resources.oreilly.com/examples/9781565926165/-/tree/master/examples/etc.

## Checker results
The project contains errors in PreparedStatements in `AccountPersistence.java` and `CustomerPersistence.java` that are detected by the checker.
Therefore, attempting to compile the project with the checker (`gradle build`) on the `main` branch will fail.
The branch `fixes` contains the fixes for these errors, so the project should compile without errors on that branch.

## Instructions to compile with checker
* Set up the test postgres database with the chinook schema:
    * Create the default postgres docker container with the schema using
      ```shell
      docker-compose up -d
      ```
    * If you're using a custom database setup instead, adjust the database URL and credentials in `extraJavacArgs` in `build.gradle`
* Make sure OPSC is available in your (local) Maven repository as described in the [OPSC](https://github.com/eisop/opsc) README file
* Specify the absolute path to the directory where the log files should be stored at the end of `build.gradle`
  (uncomment the -AopsLogDir line in `extraJavacArgs` and replace the path)
* Run `./gradlew build` to compile the project with the checker