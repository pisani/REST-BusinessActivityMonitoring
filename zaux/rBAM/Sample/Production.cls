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
    <Setting Target="Adapter" Name="URL"></Setting>
    <Setting Target="Adapter" Name="SSLConfig">GMail SSL</Setting>
    <Setting Target="Adapter" Name="Credentials"></Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Host" Name="ClassNamePrefix">1</Setting>
    <Setting Target="Host" Name="ServiceClassNames">EnvironmentMetrics</Setting>
    <Setting Target="Host" Name="MetricParameters">0</Setting>
    <Setting Target="Host" Name="HideMetrics">::CO2Level,::CurrentHumidity</Setting>
    <Setting Target="Host" Name="PathForDebugFile">c:/temp</Setting>
    <Setting Target="Host" Name="CallInterval">5</Setting>
  </Item>
  <Item Name="EnvironmentMetrics" Category="" ClassName="zaux.rBAM.Sample.MetricClass" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
