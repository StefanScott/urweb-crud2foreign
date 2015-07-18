table status : {Id : int, Nam : string}
  PRIMARY KEY Id
  CONSTRAINT Nam UNIQUE Nam

table t : {
  Id : int, 
  Nam : string, 
  Ready : bool, 
  ForeignStatus : int }
  PRIMARY KEY Id
  CONSTRAINT ForeignStatus 
    FOREIGN KEY ForeignStatus 
    REFERENCES status(Id)

open Crud.Make(struct
  val tab = t
  
  val title = "Are you Ready? Select a Foreign Status."

  val cols = {
    Nam = Crud.string "Name",

    Ready = {
      Nam = "Ready?",

      Show = (fn b => 
       if b then
         <xml>Ready!</xml>
       else
         <xml>Not ready</xml>),

      Widget = (fn [nm :: Name] => 
        <xml>
          <select{nm}>
            <option>Ready</option>
            <option>Not ready</option>
          </select>
        </xml>),

      WidgetPopulated = (fn [nm :: Name] b => 
      <xml>
        <select{nm}>
          <option selected={b}>Ready</option>
          <option selected={not b}>Not ready</option>
        </select>
      </xml>),

      Parse = (fn s =>
        case s of
            "Ready" => True
          | "Not ready" => False
          | _ => error <xml>Invalid ready/not ready</xml>),

      Inject = _
    },

    ForeignStatus = {
      Nam = "Foreign Status",
  
      Show = (fn fs =>
        statusNam <- oneRowE1 (SELECT Nam FROM status WHERE Id = {[fs]});
        return statusNam;
        <xml>{statusNam}</xml>
      ),

      Widget = (fn [nm :: Name] => 
        statusOptions <- 
          queryX1 (SELECT Id, Nam FROM status ORDER BY Nam) 
          (fn r => <xml><coption value={r.Id}>{r.Nam}</coption></xml>);
        return statusOptions;
        <xml>
          <select{nm}>
            {statusOptions}
          </select>
        </xml>),

      WidgetPopulated = (fn [nm :: Name] fsId => 
        statusOptionsPop <- 
          queryX1 (SELECT status.Id, status.Nam FROM status ORDER BY status.Nam) 
          (fn r => <xml><coption value={r.Id} selected={r.Id=fsId}>{r.Nam}</coption></xml>);
        return statusOptionsPop;
        <xml>
          <select{nm}>
            {statusOptionsPop}
          </select>
        </xml>),

      Parse = (fn fsNam =>
        fsId <- oneRowE1 (SELECT Id FROM status WHERE Nam = {[fsNam]});
        return fsId;
        fsId),

      Inject = _
    }
  }
end)