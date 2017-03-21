ruleset track_trips_2 {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    shares process_trip
  }

  global {
    long_trip = 10
  }

  rule process_trip {
    select when car new_trip
    pre {
      mileage = event:attr("mileage")
      timestamp = time:now()
      new_attrs = event:attrs().put({"time": timestamp})
    }
    send_directive("trip") with
      trip_length = new_attrs
    fired {
      raise explicit event "trip_processed"
        attributes new_attrs
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage").defaultsTo(0).as("Number")
    }
    fired {
      raise explicit event "found_long_trip"
        attributes event:attrs()
        if (mileage >= long_trip)
    }
  }
}