<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Returned_To_Support_Check_Box</fullName>
        <field>Was_Ever_Returned_to_Support__c</field>
        <literalValue>1</literalValue>
        <name>Check Returned To Support Check Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>P4_status</fullName>
        <field>Perforce_Status__c</field>
        <name>P4 status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear P4 Status</fullName>
        <actions>
            <name>P4_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ADM_Work__c.Resolved__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Clear P4 status when the work record resolved value becomes 1</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Close Work</fullName>
        <actions>
            <name>Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ADM_Work__c.Stage__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
