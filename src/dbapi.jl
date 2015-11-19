# DBAPI implementation for ODBC.jl

using DBAPI

import Base: close
import DBAPI: show, execute!

abstract ODBCInterface <: DatabaseInterface

type ODBCDatabaseError <: DatabaseError{ODBCInterface}
end

type ODBCConnection <: DatabaseConnection{ODBCInterface}
    conn::Connection
end

type ODBCCursor <: DatabaseCursor{ODBCInterface}
    conn::ODBCConnection
end

export ODBCInterface, ODBCDatabaseError, ODBCConnection, ODBCCursor

connect(::Type{ODBCInterface}, dsn; usr="", pwd="") =
    ODBCConnection(ODBC.connect(dsn, usr=usr, pwd=pwd))

show(io::IO, conn::ODBCConnection) = show(io, conn.conn)
show(io::IO, csr::ODBCCursor) = print(io, typeof(csr), "(", connection(csr), ")")

function close(conn::ODBCConnection)
    ODBC.disconnect(conn.conn)
    return nothing
end

cursor(conn::ODBCConnection) = ODBCCursor(conn)
connection(csr::ODBCCursor) = csr.conn

function execute!(csr::ODBCCursor, qry::DatabaseQuery, parameters=())
    ODBC.query(qry.query, csr.conn.conn)
end

export connect, close, cursor, execute!
