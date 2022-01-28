require "rails_helper"
require "action_view"

RSpec.describe "addtional_expenses", type: :system do
  it "additional expenses fields appearance", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    check "School"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_miles_driven", with: "0"

    expect(page).to have_text("Add another expense")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "5.34")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Lunch")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(1)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "5.34")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Lunch")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_2_other_expense_amount")
  end
  it "additional expenses for multiple entries", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    check "School"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_miles_driven", with: "0"

    expect(page).to have_text("Add another expense")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "7.21")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Toll")

    click_on "Add another expense"
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_2_other_expense_amount")

    find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.22")
    find_by_id("case_contact_additional_expenses_attributes_1_other_expenses_describe").fill_in(with: "Another Toll")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(2)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "7.21")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.22")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "Another Toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount")

    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Breakfast")
    find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.23")
    find_by_id("case_contact_additional_expenses_attributes_2_other_expense_amount").fill_in(with: "8.23")
    find_by_id("case_contact_additional_expenses_attributes_2_other_expenses_describe").fill_in(with: "Yet another toll")

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(1)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount", with: "8.23")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expenses_describe", with: "Yet another toll")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Breakfast")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.23")
    expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
    click_on "Add another expense"
    expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
  end
  it "additional expenses for maximum entries", js: true do
    FeatureFlagService.enable!("show_additional_expenses")
    organization = build(:casa_org)
    volunteer = create(:volunteer, casa_org: organization)
    casa_case = create(:casa_case, casa_org: organization)
    create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
    contact_type_group = build(:contact_type_group, casa_org: organization)
    create(:contact_type)
    create(:contact_type, name: "School", contact_type_group: contact_type_group)

    sign_in volunteer

    visit casa_case_path(casa_case.id)

    click_on "New Case Contact"

    check "School"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"
    fill_in "case_contact_miles_driven", with: "0"

    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expense_amount")
    expect(page).to have_no_field("case_contact_additional_expenses_attributes_1_other_expenses_describe")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expense_amount").fill_in(with: "0.11")
    find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "1 meal")

    (1..9).each { |i|
      click_on "Add another expense"
      expect(page).to have_field("case_contact_additional_expenses_attributes_#{i}_other_expense_amount")
      expect(page).to have_field("case_contact_additional_expenses_attributes_#{i}_other_expenses_describe")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_#{i+1}_other_expense_amount")
      expect(page).to have_no_field("case_contact_additional_expenses_attributes_#{i+1}_other_expenses_describe")
      find_by_id("case_contact_additional_expenses_attributes_#{i}_other_expense_amount").fill_in(with: "#{i}.11")
      find_by_id("case_contact_additional_expenses_attributes_#{i}_other_expenses_describe").fill_in(with: "#{i+1} meal")
    }

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1).and change(AdditionalExpense, :count).by(10)

    visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    expect(page).to have_text("Editing Case Contact")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expense_amount", with: "0.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "1 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "1.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "2 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount", with: "2.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expenses_describe", with: "3 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expense_amount", with: "3.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expenses_describe", with: "4 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expense_amount", with: "4.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expenses_describe", with: "5 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_5_other_expense_amount", with: "5.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_5_other_expenses_describe", with: "6 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_6_other_expense_amount", with: "6.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_6_other_expenses_describe", with: "7 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_7_other_expense_amount", with: "7.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_7_other_expenses_describe", with: "8 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_8_other_expense_amount", with: "8.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_8_other_expenses_describe", with: "9 meal")
    expect(page).to have_field("case_contact_additional_expenses_attributes_9_other_expense_amount", with: "9.11")
    expect(page).to have_field("case_contact_additional_expenses_attributes_9_other_expenses_describe", with: "10 meal")

    expect(page).to have_no_field("case_contact_additional_expenses_attributes_10_other_expense_amount") #should fail sb no field LEFT OFF HERE, SB no field 10!!!!! Add limiter to decorator at 10 count?

    # expect(page).to have_field("case_contact_additional_expenses_attributes_10_other_expenses_describe") #should fail sb no field



    # expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.22")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expenses_describe", with: "Another Toll")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount")

    # find_by_id("case_contact_additional_expenses_attributes_0_other_expenses_describe").fill_in(with: "Breakfast")
    # find_by_id("case_contact_additional_expenses_attributes_1_other_expense_amount").fill_in(with: "7.23")
    # find_by_id("case_contact_additional_expenses_attributes_2_other_expense_amount").fill_in(with: "8.23")
    # find_by_id("case_contact_additional_expenses_attributes_2_other_expenses_describe").fill_in(with: "Yet another toll")

    # expect {
    #   click_on "Submit"
    # }.to change(CaseContact, :count).by(0).and change(AdditionalExpense, :count).by(1)

    # visit edit_case_contact_path(casa_case.reload.case_contacts.last)
    # expect(page).to have_text("Editing Case Contact")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expense_amount", with: "8.23")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_2_other_expenses_describe", with: "Yet another toll")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_0_other_expenses_describe", with: "Breakfast")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_1_other_expense_amount", with: "7.23")
    # expect(page).to have_field("case_contact_additional_expenses_attributes_3_other_expense_amount")
    # expect(page).to have_no_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
    # click_on "Add another expense"
    # expect(page).to have_field("case_contact_additional_expenses_attributes_4_other_expense_amount")
  end
end
