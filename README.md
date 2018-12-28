

This model must contain information about:
  Orders
  Customers
  Shipments
  Wherehouses
  Vehicles
  
Mandatory requirements:
  Each order is comprised of different products and has only only client.
  Each client may have more than one address and can be both a person or a company.
  The deliveries must have a beginning and an end adress, but can contain different legs(for example a truck needs to get from Sofia to Stara Zagora, but must make a stop in Plovediv - so the delivery has two legs).
  The initial address i always a warehouse address. The end address is always a client's address. The rest of the addresses are not restricted, but if they are either a warehouse or a client address, the client/warehouse must be recorded.
  Each delivery consist of products, which may be from different orders and for different clients.
  Some orders may be partially (or fully) returned by clients. Returned products and the reason of returning them must be recorded.
  The vehicle for each delivery must be recorded. If the driver during a particular delivery is and employee of the complany, their ID must be recorded.
 
Queries about the following should be supported:
  The speed of client deliveries grouped by geographucal area (city, country) and by ype of vehicle.
  The average fuel consumation by brand and model of the vehicle, driver, time of the day and my weather condition.
  
