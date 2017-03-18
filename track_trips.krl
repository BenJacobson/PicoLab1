ruleset track_trips {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    shares process_trip
  }

  rule process_trip {
    select when echo message
    pre {
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip_length = mileage
  }
}