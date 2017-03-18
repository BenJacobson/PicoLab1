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
    }
    send_directive("trip") with
      trip_length = mileage
    fired {
      raise explicit event trip_processed
        attributes event:attr()
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage").as("Number")
    }
    fired {
      last if mileage < long_trip;
      raise explicit event found_long_trip
    }
  }
}