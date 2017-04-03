ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    author "Ben Jacobson"
    logging on
    shares
  }

  rule create_vehicle {
    select car when new_vehicle

    pre {
    name = event:attr("name");
    owner = event:attr("owner");
    attributes = {}
      .put(["name"], name)
      .put(["owner"], owner)
      .put(["Prototype_rids"], "b507780x54.prod, b507780x56.prod"); // Installs rule sets b507780x54.prod and b507780x56.prod in the newly created Pico
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_creation") with attrs = attributes.klog("attributes: ");
      send_directive("Item created") with attributes = "#{attributes}" and name = "#{name}"
    }
    always {
      log("Create child item for " + child);
    }
  }
}