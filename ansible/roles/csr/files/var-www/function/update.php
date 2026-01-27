<?php
// Include the database connection file
include_once("mariadb-config.php");

echo "webserver: " . $_SERVER['SERVER_ADDR'];
echo "<br>";
echo "real IP: " . $_SERVER["HTTP_X_FORWARDED_FOR"];
echo "<br>";
echo "<br>";

// UPDATE data section

$random = uniqid();
$username = 'user_'.$random;
$email = 'user_'.$random.'@gmail.com';
$id = 2519;

$sql = "UPDATE users SET username = ?, email = ? WHERE id = ?";

try {

        $query = $mysqli->prepare($sql);
        $query->bind_param("ssi", $username, $email, $id);
        if (!$query->execute()) {
                echo "Update data failed! " . $query->error;
                error_log($query->error);
        } else {
                echo "Update data with " . $sql . " successfully! <br>";
        }

}
catch (mysqli_sql_exception $e) {

        if (str_contains($e->getMessage(), 'read-only')) {
                echo "This DB is READ-ONLY (slave) <br>";
                echo $e->getMessage() . "<br>";
        } else {
                echo "DB Error: " . $e->getMessage() . "<br>";
        }

        error_log($e->getMessage());

}

$result = mysqli_query($mysqli, "SELECT * FROM users WHERE id = 2519;");
while ($row = mysqli_fetch_assoc($result)) {
        echo "id: " . $row["id"]. " - Name: " . $row["username"]. " - Email: ". $row["email"]. " - Created At: ". $row["created_at"]. "<br>";
}
?>
