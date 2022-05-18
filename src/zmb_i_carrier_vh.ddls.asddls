@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Input Help - Carrier'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMB_I_CARRIER_VH as select from /dmo/carrier {
@UI.lineItem: [{position: 10, importance: #HIGH }]
    key carrier_id as CarrierId,
@UI.lineItem: [{position: 20, importance: #HIGH }]    
    name as Name
}
