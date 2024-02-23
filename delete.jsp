<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    Connection connection = null;

    try {
        // Establish database connection (Update with your database URL, username, and password)
        String url = "jdbc:mysql://your_database_url:3306/your_database";
        String username = "your_username";
        String password = "your_password";
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(url, username, password);

        // Handling the form submission for deletion
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String[] deleteIds = request.getParameterValues("deleteIds");

            if (deleteIds != null && deleteIds.length > 0) {
                PreparedStatement preparedStatement = null;

                try {
                    // Delete selected rows from the database
                    String query = "DELETE FROM your_table WHERE id IN (" +
                            String.join(",", Collections.nCopies(deleteIds.length, "?")) + ")";
                    preparedStatement = connection.prepareStatement(query);

                    for (int i = 0; i < deleteIds.length; i++) {
                        preparedStatement.setInt(i + 1, Integer.parseInt(deleteIds[i]));
                    }

                    preparedStatement.executeUpdate();
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    // Close resources
                    if (preparedStatement != null) preparedStatement.close();
                }
            }

            // Redirect back to the main page after deletion
            response.sendRedirect("main.jsp");
            return;
        }

        // Displaying the database content
        Statement statement = null;
        ResultSet resultSet = null;

        try {
            statement = connection.createStatement();
            String query = "SELECT * FROM your_table";
            resultSet = statement.executeQuery(query);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Database Content</title>
</head>
<body>

    <form action="main.jsp" method="post">
        <table border="1">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Delete</th>
                </tr>
            </thead>
            <tbody>
<%
            while (resultSet.next()) {
%>
                <tr>
                    <td><%= resultSet.getInt("id") %></td>
                    <td><%= resultSet.getString("name") %></td>
                    <td><%= resultSet.getString("description") %></td>
                    <td><input type="checkbox" name="deleteIds" value="<%= resultSet.getInt("id") %>"></td>
                </tr>
<%
            }
%>
            </tbody>
        </table>
        <br>
        <input type="submit" value="Delete Selected Rows">
    </form>

<%
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Close resources
            try {
                if (resultSet != null) resultSet.close();
                if (statement != null) statement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
    } finally {
        // Close the main connection
        try {
            if (connection != null) connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

</body>
</html>
