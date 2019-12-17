Class zaux.rBAM.Sample.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="zaux.rBAM.Sample.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
   <Item Name="zaux.bs.SampleMetrics" Category="" ClassName="zaux.bs.SampleMetrics" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">5</Setting>
  </Item>
  <Item Name="zaux.rBAM.Operation" Category="" ClassName="zaux.rBAM.Operation" PoolSize="1" Enabled="true" Foreground="true" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="StructuredOutput">0</Setting>
    <Setting Target="Adapter" Name="HTTPPort">443</Setting>
    <Setting Target="Adapter" Name="HTTPServer">api.powerbi.com</Setting>
    <Setting Target="Adapter" Name="URL">beta/74abaa74-2829-4279-b25c-5743687b0bf5/datasets/7639df1a-0818-46ba-ad5b-9bf8f37b5771/rows?key=kYL0FJHTxOajAu0XfYj%2BnfGRsCJmx0%2FYnWhGoyvWqqaUj4A90HgowK4vyqq1%2BahspqN2i8XQncUv6bV0C6XS9Q%3D%3D</Setting>
    <Setting Target="Adapter" Name="SSLConfig">GMail SSL</Setting>
    <Setting Target="Adapter" Name="Credentials">PowerBI</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Host" Name="ClassNamePrefix">0</Setting>
  </Item>
</Production>
}

}
