Class zaux.rBAM.Sample.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="zaux.rBAM.Sample.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="zaux.rBAM.Operation" Category="" ClassName="zaux.rBAM.Operation" PoolSize="1" Enabled="true" Foreground="true" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="StructuredOutput">0</Setting>
    <Setting Target="Adapter" Name="HTTPPort">443</Setting>
    <Setting Target="Adapter" Name="HTTPServer">api.powerbi.com</Setting>
    <Setting Target="Adapter" Name="URL">beta/74abaa74-2829-4279-b25c-5743687b0bf5/datasets/7dfa5421-95ff-4fec-a807-39388b6e2479/rows?key=kOwf7G9reaoNraYi6C3M5NNqoHnQuYjMpYQ4G%2BE2Rm4BDxuekpyle4ojdqZZAGRFMWejYJ3y0RhWQQKN1%2F%2Ft2g%3D%3D</Setting>
    <Setting Target="Adapter" Name="SSLConfig">GMail SSL</Setting>
    <Setting Target="Adapter" Name="Credentials">PowerBI</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Host" Name="ClassNamePrefix">1</Setting>
    <Setting Target="Host" Name="ServiceClassNames">EnvironmentalMetrics</Setting>
    <Setting Target="Host" Name="MetricParameters">0</Setting>
    <Setting Target="Host" Name="HideMetrics">::CO2Level,::CurrentHumidity</Setting>
    <Setting Target="Host" Name="PathForDebugFile">c:/temp</Setting>
  </Item>
  <Item Name="EnvironmentalMetrics" Category="" ClassName="zaux.rBAM.Sample.MetricClass" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
