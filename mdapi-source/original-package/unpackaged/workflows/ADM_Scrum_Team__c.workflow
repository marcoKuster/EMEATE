<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Record_Type_Copy</fullName>
        <field>Copy_Record_Type_Name__c</field>
        <formula>$RecordType.Name</formula>
        <name>Update Record Type Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set program initial section headers</fullName>
        <active>false</active>
        <criteriaItems>
            <field>ADM_Scrum_Team__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Program</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Record Type Copy</fullName>
        <actions>
            <name>Update_Record_Type_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ADM_Scrum_Team__c.RecordTypeId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
