import CoreData
import Foundation

public class PersistenceController {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        // Using a custom managed object model to avoid bundle lookup issues in SPM for this scaffold
        let model = PersistenceController.managedObjectModel()
        container = NSPersistentContainer(name: "NexusEnterprise", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Programmatic Core Data Model
    // We define the model programmatically to simplify SPM resource handling for this scaffold
    static func managedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // CUSTOMER
        let customerEntity = NSEntityDescription()
        customerEntity.name = "Customer"
        customerEntity.managedObjectClassName = "Customer" // We will generate this class or use NSManagedObject
        
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        
        let emailAttribute = NSAttributeDescription()
        emailAttribute.name = "email"
        emailAttribute.attributeType = .stringAttributeType
        emailAttribute.isOptional = true
        
        // New CRM fields
        let ltvAttr = NSAttributeDescription()
        ltvAttr.name = "lifetimeValue"
        ltvAttr.attributeType = .doubleAttributeType
        ltvAttr.defaultValue = 0.0
        ltvAttr.isOptional = false
        
        let stageAttr = NSAttributeDescription()
        stageAttr.name = "lifecycleStage"
        stageAttr.attributeType = .stringAttributeType
        stageAttr.defaultValue = "Lead"
        stageAttr.isOptional = false
        
        // CONTRACT
        let contractEntity = NSEntityDescription()
        contractEntity.name = "Contract"
        contractEntity.managedObjectClassName = "Contract"
        
        let contractIdAttr = NSAttributeDescription()
        contractIdAttr.name = "id"
        contractIdAttr.attributeType = .UUIDAttributeType
        contractIdAttr.isOptional = false
        
        let contractTitleAttr = NSAttributeDescription()
        contractTitleAttr.name = "title"
        contractTitleAttr.attributeType = .stringAttributeType
        contractTitleAttr.isOptional = false
        
        let contractValueAttr = NSAttributeDescription()
        contractValueAttr.name = "value"
        contractValueAttr.attributeType = .doubleAttributeType
        contractValueAttr.isOptional = false
        
        let contractStartAttr = NSAttributeDescription()
        contractStartAttr.name = "startDate"
        contractStartAttr.attributeType = .dateAttributeType
        contractStartAttr.isOptional = false
        
        let contractEndAttr = NSAttributeDescription()
        contractEndAttr.name = "endDate"
        contractEndAttr.attributeType = .dateAttributeType
        contractEndAttr.isOptional = false
        
        let contractStatusAttr = NSAttributeDescription()
        contractStatusAttr.name = "status"
        contractStatusAttr.attributeType = .stringAttributeType
        contractStatusAttr.defaultValue = "Draft"
        contractStatusAttr.isOptional = false
        
        // Relationship Contract -> Customer
        let contractToCustomer = NSRelationshipDescription()
        contractToCustomer.name = "customer"
        contractToCustomer.destinationEntity = customerEntity
        contractToCustomer.maxCount = 1
        contractToCustomer.minCount = 1
        contractToCustomer.deleteRule = .nullifyDeleteRule // or cascade if strict
        contractToCustomer.isOptional = false
        
        // Relationship Customer -> Contracts
        let customerToContracts = NSRelationshipDescription()
        customerToContracts.name = "contracts"
        customerToContracts.destinationEntity = contractEntity
        customerToContracts.maxCount = 0 // to-many
        customerToContracts.minCount = 0
        customerToContracts.deleteRule = .cascadeDeleteRule
        customerToContracts.inverseRelationship = contractToCustomer
        
        contractToCustomer.inverseRelationship = customerToContracts
        
        customerEntity.properties = [idAttribute, nameAttribute, emailAttribute, ltvAttr, stageAttr, customerToContracts]
        contractEntity.properties = [contractIdAttr, contractTitleAttr, contractValueAttr, contractStartAttr, contractEndAttr, contractStatusAttr, contractToCustomer]
        
        // INVOICE
        let invoiceEntity = NSEntityDescription()
        invoiceEntity.name = "Invoice"
        invoiceEntity.managedObjectClassName = "Invoice"
        
        let invIdAttr = NSAttributeDescription()
        invIdAttr.name = "id"
        invIdAttr.attributeType = .UUIDAttributeType
        invIdAttr.isOptional = false
        
        let invNumAttr = NSAttributeDescription()
        invNumAttr.name = "invoiceNumber"
        invNumAttr.attributeType = .stringAttributeType
        invNumAttr.isOptional = false
        
        let invIssuedAttr = NSAttributeDescription()
        invIssuedAttr.name = "issueDate"
        invIssuedAttr.attributeType = .dateAttributeType
        invIssuedAttr.isOptional = false
        
        let invDueAttr = NSAttributeDescription()
        invDueAttr.name = "dueDate"
        invDueAttr.attributeType = .dateAttributeType
        invDueAttr.isOptional = false
        
        let invTotalAttr = NSAttributeDescription()
        invTotalAttr.name = "totalAmount"
        invTotalAttr.attributeType = .doubleAttributeType
        invTotalAttr.isOptional = false
        
        let invStatusAttr = NSAttributeDescription()
        invStatusAttr.name = "status"
        invStatusAttr.attributeType = .stringAttributeType
        invStatusAttr.isOptional = false
        
        // Relationship Invoice -> Customer
        let invoiceToCustomer = NSRelationshipDescription()
        invoiceToCustomer.name = "customer"
        invoiceToCustomer.destinationEntity = customerEntity
        invoiceToCustomer.maxCount = 1
        invoiceToCustomer.minCount = 1
        invoiceToCustomer.deleteRule = .nullifyDeleteRule
        invoiceToCustomer.isOptional = false
        
        invoiceEntity.properties = [invIdAttr, invNumAttr, invIssuedAttr, invDueAttr, invTotalAttr, invStatusAttr, invoiceToCustomer]
        
        // LEDGER ENTRY
        let ledgerEntity = NSEntityDescription()
        ledgerEntity.name = "LedgerEntry"
        ledgerEntity.managedObjectClassName = "LedgerEntry"
        
        let ldgIdAttr = NSAttributeDescription()
        ldgIdAttr.name = "id"
        ldgIdAttr.attributeType = .UUIDAttributeType
        ldgIdAttr.isOptional = false
        
        let ldgDateAttr = NSAttributeDescription()
        ldgDateAttr.name = "entryDate"
        ldgDateAttr.attributeType = .dateAttributeType
        ldgDateAttr.isOptional = false
        
        let ldgDescAttr = NSAttributeDescription()
        ldgDescAttr.name = "userDescription"
        ldgDescAttr.attributeType = .stringAttributeType
        ldgDescAttr.isOptional = false
        
        let ldgAccAttr = NSAttributeDescription()
        ldgAccAttr.name = "accountCode"
        ldgAccAttr.attributeType = .stringAttributeType
        ldgAccAttr.isOptional = false
        
        let ldgDebitAttr = NSAttributeDescription()
        ldgDebitAttr.name = "debitAmount"
        ldgDebitAttr.attributeType = .doubleAttributeType
        ldgDebitAttr.defaultValue = 0.0
        ldgDebitAttr.isOptional = false
        
        let ldgCreditAttr = NSAttributeDescription()
        ldgCreditAttr.name = "creditAmount"
        ldgCreditAttr.attributeType = .doubleAttributeType
        ldgCreditAttr.defaultValue = 0.0
        ldgCreditAttr.isOptional = false
        
        ledgerEntity.properties = [ldgIdAttr, ldgDateAttr, ldgDescAttr, ldgAccAttr, ldgDebitAttr, ldgCreditAttr]
    
        // PROJECT
        let projectEntity = NSEntityDescription()
        projectEntity.name = "Project"
        projectEntity.managedObjectClassName = "Project"
        
        let projIdAttr = NSAttributeDescription()
        projIdAttr.name = "id"
        projIdAttr.attributeType = .UUIDAttributeType
        projIdAttr.isOptional = false
        
        let projNameAttr = NSAttributeDescription()
        projNameAttr.name = "name"
        projNameAttr.attributeType = .stringAttributeType
        projNameAttr.isOptional = false
        
        let projStatusAttr = NSAttributeDescription()
        projStatusAttr.name = "status"
        projStatusAttr.attributeType = .stringAttributeType
        projStatusAttr.defaultValue = "Active"
        projStatusAttr.isOptional = false
        
        let projDescAttr = NSAttributeDescription()
        projDescAttr.name = "projectDescription"
        projDescAttr.attributeType = .stringAttributeType
        projDescAttr.isOptional = true
        
        let projDeadlineAttr = NSAttributeDescription()
        projDeadlineAttr.name = "deadline"
        projDeadlineAttr.attributeType = .dateAttributeType
        projDeadlineAttr.isOptional = true
        
        projectEntity.properties = [projIdAttr, projNameAttr, projStatusAttr, projDescAttr, projDeadlineAttr]
        
        // LOG ENTRY
        let logEntity = NSEntityDescription()
        logEntity.name = "LogEntry"
        logEntity.managedObjectClassName = "LogEntry"
        
        let logIdAttr = NSAttributeDescription()
        logIdAttr.name = "id"
        logIdAttr.attributeType = .UUIDAttributeType
        logIdAttr.isOptional = false
        
        let logTimeAttr = NSAttributeDescription()
        logTimeAttr.name = "timestamp"
        logTimeAttr.attributeType = .dateAttributeType
        logTimeAttr.isOptional = false
        
        let logContentAttr = NSAttributeDescription()
        logContentAttr.name = "content"
        logContentAttr.attributeType = .stringAttributeType
        logContentAttr.isOptional = false
        
        let logSentimentAttr = NSAttributeDescription()
        logSentimentAttr.name = "sentiment"
        logSentimentAttr.attributeType = .stringAttributeType
        logSentimentAttr.isOptional = true
        
        let logTagsAttr = NSAttributeDescription()
        logTagsAttr.name = "tags"
        logTagsAttr.attributeType = .stringAttributeType
        logTagsAttr.isOptional = true
        
        logEntity.properties = [logIdAttr, logTimeAttr, logContentAttr, logSentimentAttr, logTagsAttr]
        
        // CAMPAIGN
        let campaignEntity = NSEntityDescription()
        campaignEntity.name = "Campaign"
        campaignEntity.managedObjectClassName = "Campaign"
        
        let campIdAttr = NSAttributeDescription()
        campIdAttr.name = "id"
        campIdAttr.attributeType = .UUIDAttributeType
        campIdAttr.isOptional = false
        
        let campNameAttr = NSAttributeDescription()
        campNameAttr.name = "name"
        campNameAttr.attributeType = .stringAttributeType
        campNameAttr.isOptional = false
        
        let campTypeAttr = NSAttributeDescription()
        campTypeAttr.name = "type"
        campTypeAttr.attributeType = .stringAttributeType
        campTypeAttr.isOptional = false
        
        let campStartAttr = NSAttributeDescription()
        campStartAttr.name = "startDate"
        campStartAttr.attributeType = .dateAttributeType
        campStartAttr.isOptional = false
        
        let campBudgetAttr = NSAttributeDescription()
        campBudgetAttr.name = "budget"
        campBudgetAttr.attributeType = .doubleAttributeType
        campBudgetAttr.isOptional = false
        
        let campStatusAttr = NSAttributeDescription()
        campStatusAttr.name = "status"
        campStatusAttr.attributeType = .stringAttributeType
        campStatusAttr.isOptional = false
        
        // SEGMENT
        let segmentEntity = NSEntityDescription()
        segmentEntity.name = "Segment"
        segmentEntity.managedObjectClassName = "Segment"
        
        let segIdAttr = NSAttributeDescription()
        segIdAttr.name = "id"
        segIdAttr.attributeType = .UUIDAttributeType
        segIdAttr.isOptional = false
        
        let segNameAttr = NSAttributeDescription()
        segNameAttr.name = "name"
        segNameAttr.attributeType = .stringAttributeType
        segNameAttr.isOptional = false
        
        let segCritAttr = NSAttributeDescription()
        segCritAttr.name = "criteria"
        segCritAttr.attributeType = .stringAttributeType
        segCritAttr.isOptional = false
        
        let segSizeAttr = NSAttributeDescription()
        segSizeAttr.name = "estimatedSize"
        segSizeAttr.attributeType = .integer64AttributeType
        segSizeAttr.isOptional = false
        
        // Relationship Campaign <-> Segment (Many to Many)
        let campaignToSegments = NSRelationshipDescription()
        campaignToSegments.name = "segments"
        campaignToSegments.destinationEntity = segmentEntity
        campaignToSegments.maxCount = 0 // Many
        campaignToSegments.minCount = 0
        campaignToSegments.deleteRule = .nullifyDeleteRule
        campaignToSegments.isOptional = true
        
        let segmentToCampaigns = NSRelationshipDescription()
        segmentToCampaigns.name = "campaigns"
        segmentToCampaigns.destinationEntity = campaignEntity
        segmentToCampaigns.maxCount = 0 // Many
        segmentToCampaigns.minCount = 0
        segmentToCampaigns.deleteRule = .nullifyDeleteRule
        segmentToCampaigns.isOptional = true
        segmentToCampaigns.inverseRelationship = campaignToSegments
        
        campaignToSegments.inverseRelationship = segmentToCampaigns
        
        campaignEntity.properties = [campIdAttr, campNameAttr, campTypeAttr, campStartAttr, campBudgetAttr, campStatusAttr, campaignToSegments]
        segmentEntity.properties = [segIdAttr, segNameAttr, segCritAttr, segSizeAttr, segmentToCampaigns]
        
        // DOCUMENT
        let documentEntity = NSEntityDescription()
        documentEntity.name = "Document"
        documentEntity.managedObjectClassName = "Document"
        
        let docIdAttr = NSAttributeDescription()
        docIdAttr.name = "id"
        docIdAttr.attributeType = .UUIDAttributeType
        docIdAttr.isOptional = false
        
        let docFilenameAttr = NSAttributeDescription()
        docFilenameAttr.name = "filename"
        docFilenameAttr.attributeType = .stringAttributeType
        docFilenameAttr.isOptional = false
        
        let docTypeAttr = NSAttributeDescription()
        docTypeAttr.name = "contentType"
        docTypeAttr.attributeType = .stringAttributeType
        docTypeAttr.isOptional = false
        
        let docContentAttr = NSAttributeDescription()
        docContentAttr.name = "rawContent"
        docContentAttr.attributeType = .stringAttributeType
        docContentAttr.isOptional = true
        
        let docIngestedAttr = NSAttributeDescription()
        docIngestedAttr.name = "ingestedAt"
        docIngestedAttr.attributeType = .dateAttributeType
        docIngestedAttr.isOptional = false
        
        let docDeptAttr = NSAttributeDescription()
        docDeptAttr.name = "department"
        docDeptAttr.attributeType = .stringAttributeType
        docDeptAttr.isOptional = true
        
        documentEntity.properties = [docIdAttr, docFilenameAttr, docTypeAttr, docContentAttr, docIngestedAttr, docDeptAttr]
        
        // INTELLIGENCE ARTIFACT
        let artifactEntity = NSEntityDescription()
        artifactEntity.name = "IntelligenceArtifact"
        artifactEntity.managedObjectClassName = "IntelligenceArtifact"
        
        let artIdAttr = NSAttributeDescription()
        artIdAttr.name = "id"
        artIdAttr.attributeType = .UUIDAttributeType
        artIdAttr.isOptional = false
        
        let artTypeAttr = NSAttributeDescription()
        artTypeAttr.name = "type"
        artTypeAttr.attributeType = .stringAttributeType
        artTypeAttr.isOptional = false
        
        let artContentAttr = NSAttributeDescription()
        artContentAttr.name = "content"
        artContentAttr.attributeType = .stringAttributeType
        artContentAttr.isOptional = false
        
        let artCreatedAttr = NSAttributeDescription()
        artCreatedAttr.name = "createdAt"
        artCreatedAttr.attributeType = .dateAttributeType
        artCreatedAttr.isOptional = false
        
        // Relationship Artifact -> Document
        let artifactToDoc = NSRelationshipDescription()
        artifactToDoc.name = "document"
        artifactToDoc.destinationEntity = documentEntity
        artifactToDoc.maxCount = 1
        artifactToDoc.minCount = 0
        artifactToDoc.deleteRule = .nullifyDeleteRule
        artifactToDoc.isOptional = true
        
        artifactEntity.properties = [artIdAttr, artTypeAttr, artContentAttr, artCreatedAttr, artifactToDoc]
        
        // CROSS LINK
        let crossLinkEntity = NSEntityDescription()
        crossLinkEntity.name = "CrossLink"
        crossLinkEntity.managedObjectClassName = "CrossLink"
        
        let clIdAttr = NSAttributeDescription()
        clIdAttr.name = "id"
        clIdAttr.attributeType = .UUIDAttributeType
        clIdAttr.isOptional = false
        
        let clSourceAttr = NSAttributeDescription()
        clSourceAttr.name = "sourceID"
        clSourceAttr.attributeType = .UUIDAttributeType
        clSourceAttr.isOptional = false
        
        let clTargetAttr = NSAttributeDescription()
        clTargetAttr.name = "targetID"
        clTargetAttr.attributeType = .UUIDAttributeType
        clTargetAttr.isOptional = false
        
        let clRelTypeAttr = NSAttributeDescription()
        clRelTypeAttr.name = "relationshipType"
        clRelTypeAttr.attributeType = .stringAttributeType
        clRelTypeAttr.isOptional = false
        
        let clWeightAttr = NSAttributeDescription()
        clWeightAttr.name = "weight"
        clWeightAttr.attributeType = .floatAttributeType
        clWeightAttr.isOptional = false
        
        let clCreatedAttr = NSAttributeDescription()
        clCreatedAttr.name = "createdAt"
        clCreatedAttr.attributeType = .dateAttributeType
        clCreatedAttr.isOptional = false
        
        crossLinkEntity.properties = [clIdAttr, clSourceAttr, clTargetAttr, clRelTypeAttr, clWeightAttr, clCreatedAttr]
        
        // PRODUCT (Marketing 4Ps)
        let productEntity = NSEntityDescription()
        productEntity.name = "Product"
        productEntity.managedObjectClassName = "Product"
        
        let prodIdAttr = NSAttributeDescription()
        prodIdAttr.name = "id"
        prodIdAttr.attributeType = .UUIDAttributeType
        prodIdAttr.isOptional = false
        
        let prodNameAttr = NSAttributeDescription()
        prodNameAttr.name = "name"
        prodNameAttr.attributeType = .stringAttributeType
        prodNameAttr.isOptional = false
        
        let prodDescAttr = NSAttributeDescription()
        prodDescAttr.name = "productDescription"
        prodDescAttr.attributeType = .stringAttributeType
        prodDescAttr.isOptional = true
        
        let prodPriceAttr = NSAttributeDescription()
        prodPriceAttr.name = "price"
        prodPriceAttr.attributeType = .doubleAttributeType
        prodPriceAttr.defaultValue = 0.0
        prodPriceAttr.isOptional = false
        
        let prodPosAttr = NSAttributeDescription()
        prodPosAttr.name = "positioning"
        prodPosAttr.attributeType = .stringAttributeType
        prodPosAttr.isOptional = true
        
        productEntity.properties = [prodIdAttr, prodNameAttr, prodDescAttr, prodPriceAttr, prodPosAttr]
        
        // JOURNAL ENTRY
        let journalEntryEntity = NSEntityDescription()
        journalEntryEntity.name = "JournalEntry"
        journalEntryEntity.managedObjectClassName = "JournalEntry"
        
        let jeIdAttr = NSAttributeDescription()
        jeIdAttr.name = "id"
        jeIdAttr.attributeType = .UUIDAttributeType
        jeIdAttr.isOptional = false
        
        let jeTitleAttr = NSAttributeDescription()
        jeTitleAttr.name = "title"
        jeTitleAttr.attributeType = .stringAttributeType
        jeTitleAttr.isOptional = false
        jeTitleAttr.defaultValue = "New Note"
        
        let jeContentAttr = NSAttributeDescription()
        jeContentAttr.name = "content"
        jeContentAttr.attributeType = .stringAttributeType
        jeContentAttr.isOptional = true
        
        let jeCreatedAttr = NSAttributeDescription()
        jeCreatedAttr.name = "createdAt"
        jeCreatedAttr.attributeType = .dateAttributeType
        jeCreatedAttr.isOptional = false
        
        journalEntryEntity.properties = [jeIdAttr, jeTitleAttr, jeContentAttr, jeCreatedAttr]
        
        // CUSTOM DEPARTMENT
        let customDeptEntity = NSEntityDescription()
        customDeptEntity.name = "CustomDepartment"
        customDeptEntity.managedObjectClassName = "CustomDepartment"
        
        let cdIdAttr = NSAttributeDescription()
        cdIdAttr.name = "id"
        cdIdAttr.attributeType = .UUIDAttributeType
        cdIdAttr.isOptional = false
        
        let cdNameAttr = NSAttributeDescription()
        cdNameAttr.name = "name"
        cdNameAttr.attributeType = .stringAttributeType
        cdNameAttr.isOptional = false
        
        let cdIconAttr = NSAttributeDescription()
        cdIconAttr.name = "iconName"
        cdIconAttr.attributeType = .stringAttributeType
        cdIconAttr.isOptional = false
        cdIconAttr.defaultValue = "folder"
        
        let cdCreatedAttr = NSAttributeDescription()
        cdCreatedAttr.name = "createdAt"
        cdCreatedAttr.attributeType = .dateAttributeType
        cdCreatedAttr.isOptional = false
        
        customDeptEntity.properties = [cdIdAttr, cdNameAttr, cdIconAttr, cdCreatedAttr]
        
        model.entities = [customerEntity, contractEntity, invoiceEntity, ledgerEntity, projectEntity, logEntity, campaignEntity, segmentEntity, documentEntity, artifactEntity, crossLinkEntity, productEntity, journalEntryEntity, customDeptEntity]
        return model
    }
}
