CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Connection
        RESULT result.

    METHODS:
      CheckSemanticKey FOR VALIDATE ON SAVE
        IMPORTING keys FOR Connection~CheckSemanticKey,

      CheckAirline FOR VALIDATE ON SAVE
        IMPORTING keys FOR Connection~CheckAirline,

      CheckOriginDestination FOR VALIDATE ON SAVE
        IMPORTING keys FOR Connection~CheckOriginDestination,
      getCities FOR DETERMINE ON SAVE
            IMPORTING keys FOR Connection~getCities.

ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD CheckSemanticKey.

    DATA ls_reported_record LIKE LINE OF reported-connection.

    DATA ls_failed_record LIKE LINE OF failed-connection.

    READ ENTITIES OF zmb_i_conn IN LOCAL MODE
      ENTITY Connection FIELDS ( uuid CarrID ConnID )
        WITH CORRESPONDING #( keys )
          RESULT DATA(connections).


    LOOP AT connections INTO DATA(ls_connection).

      "Select data from database and draft table
      SELECT FROM zmbtt_conn
       FIELDS uuid
        WHERE carrid = @ls_connection-CarrID
          AND connid = @ls_connection-ConnID
      UNION
      SELECT FROM zmbdraftconn
       FIELDS uuid
        WHERE carrid = @ls_connection-CarrID
          AND connid = @ls_connection-ConnID
      INTO TABLE @DATA(lt_connection).

      IF lt_connection IS NOT INITIAL.

        DATA(lv_msg) = me->new_message(
                         id       = 'ZMB_MSG'
                         number   = '001'
                         severity = ms-error
                         v1       = ls_connection-CarrID
                         v2       = ls_connection-ConnID
                       ).

        ls_reported_record-%tky = ls_connection-%tky.
        ls_reported_record-%msg = lv_msg.
        ls_reported_record-%element-carrid = if_abap_behv=>mk-on.
        ls_reported_record-%element-connid = if_abap_behv=>mk-on.
        APPEND ls_reported_record TO reported-connection.


        ls_failed_record-%tky = ls_connection-%tky.
        APPEND ls_failed_record TO failed-connection.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckAirline.

    DATA failed_record LIKE LINE OF failed-connection.

    DATA reported_record LIKE LINE OF reported-connection.

    READ ENTITIES OF zmb_i_conn IN LOCAL MODE
     ENTITY Connection FIELDS ( carrid )
      WITH CORRESPONDING #( keys )
       RESULT DATA(connections).

    LOOP AT connections INTO DATA(ls_connection).
      SELECT SINGLE FROM /dmo/i_carrier
       FIELDS @abap_true
        WHERE AirlineID = @ls_connection-carrID
         INTO @DATA(exists).

      IF exists = abap_false.

        DATA(lv_message) = me->new_message(
                          id = 'ZMB_MSG'
                          number = '002'
                          severity = ms-error
                          v1 = ls_connection-carrid ).


        reported_record-%tky = ls_connection-%tky.
        reported_record-%msg = lv_message.
        reported_record-%element-carrid = if_abap_behv=>mk-on.
        APPEND reported_Record TO reported-connection.


        failed_record-%tky = ls_connection-%tky.
        APPEND failed_Record TO failed-connection.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckOriginDestination.

    DATA ls_reported_record LIKE LINE OF reported-connection.

    DATA ls_failed_record LIKE LINE OF failed-connection.

    READ ENTITIES OF zmb_i_conn IN LOCAL MODE
     ENTITY Connection
      FIELDS ( AirportFrom AirportTo )
       WITH CORRESPONDING #( keys )
        RESULT DATA(connections).

    LOOP AT connections INTO DATA(ls_connection).

      IF ls_connection-cityfrom = ls_connection-cityto.

        DATA(message) = me->new_message(
                          id = 'ZMB_MSG'
                          number = '003'
                          severity = ms-error ).


        ls_reported_record-%tky = ls_connection-%tky.
        ls_reported_record-%msg = message.
        ls_reported_record-%element-carrid = if_abap_behv=>mk-on.
        ls_reported_record-%element-connid = if_abap_behv=>mk-on.
        APPEND ls_reported_record TO reported-connection.

        ls_failed_record-%tky = ls_connection-%tky.
        APPEND ls_failed_record TO failed-connection.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD getCities.

    DATA lt_data TYPE TABLE FOR READ RESULT zmb_i_conn.

    DATA lt_t_update TYPE TABLE FOR UPDATE zmb_i_conn.

    READ ENTITIES OF zmb_i_conn IN LOCAL MODE
     ENTITY Connection
      FIELDS ( CityFrom CityTo )
       WITH CORRESPONDING #( keys )
        RESULT lt_data.

    LOOP AT lt_data INTO DATA(ls_data).

      SELECT SINGLE FROM /DMO/I_Airport
        FIELDS City, CountryCode
         WHERE AirportID = @ls_data-AirportFrom
          INTO (@ls_data-CityFrom, @ls_data-CountryFrom).

      SELECT SINGLE FROM /DMO/I_Airport
        FIELDS City, CountryCode
         WHERE AirportID = @ls_data-AirportTo
          INTO (@ls_data-CityTo, @ls_data-CountryTo).


      MODIFY lt_data FROM ls_data.

    ENDLOOP.

    lt_t_update = CORRESPONDING #( lt_data ).

  ENDMETHOD.

ENDCLASS.
