@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZMB_I_CONN'
define root view entity ZMB_C_CONN
  as projection on ZMB_I_CONN
{
  key uuid,
  carrid,
  connid,
  airportfrom,
  cityfrom,
  countryfrom,
  airportto,
  cityto,
  countryto,
  locallastchangedat
  
}
