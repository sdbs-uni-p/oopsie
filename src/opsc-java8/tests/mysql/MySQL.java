package mysql;

import java.sql.*;

class MySQL {

    void date(Connection conn) throws SQLException {
        Statement st = null;
        st = conn.createStatement();
        ResultSet rs =
                st.executeQuery(
                        "select r.provider_no, ID, c_finalEDB\n"
                                + "      from formONAREnhancedRecord r\n"
                                + "      where r.ID = 123\n"
                                + "        and c_finalEDB!=''\n"
                                + "        AND c_finalEDB IS NOT NULL\n"
                                + "        GROUP BY provider_no");
    }

    void date2(Connection conn) throws SQLException {}
}
