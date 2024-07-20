// Define a function to map numeric status to string status
String getStatusString(int status) {
  switch (status) {
    case 0:
      return "Pending";
    case 1:
      return "Order Confirmed";
    case 2:
      return "Pick up the item";
    case 3:
      return "Ongoing";
    case 4:
      return "Wait for Payment";
    case 5:
      return "Order Delivered";
    case -1:
      return "Order Cancelled";
    // Add more cases as needed for other statuses
    default:
      return "Unknown Status";
  }
}
