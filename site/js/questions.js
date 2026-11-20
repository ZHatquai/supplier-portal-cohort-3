/* Question list for the Supplier Sustainability Portal.
 * Generated from reference/The_Corporate_Supplier_Questionnaire_2026_39.xlsx (sheet, row, column D text,
 * type, ESRS reference and the workbook's own dropdown options). Do not reword; regenerate if the workbook changes.
 * Used by the page (window.TC_QUESTIONS) and bundled into the Netlify functions (module.exports). */
(function (root) {
  var data = {
    "sheet": "Supplier Assessment 2026",
    "sections": [
      {
        "id": "S1",
        "title": "General Information & EcoVadis Bypass",
        "esrs": "All ESRS"
      },
      {
        "id": "S2",
        "title": "Climate & Decarbonisation",
        "esrs": "ESRS E1"
      },
      {
        "id": "S3",
        "title": "Pollution & PFAS",
        "esrs": "ESRS E2"
      },
      {
        "id": "S4",
        "title": "Water & Marine Resources",
        "esrs": "ESRS E3"
      },
      {
        "id": "S5",
        "title": "Circular Economy & Waste",
        "esrs": "ESRS E5"
      },
      {
        "id": "S6",
        "title": "Biodiversity & Ecosystems",
        "esrs": "ESRS E4"
      },
      {
        "id": "S7",
        "title": "Social, Labour & Governance",
        "esrs": "ESRS S2 · G1"
      }
    ],
    "questions": [
      {
        "id": "S1-1",
        "row": 6,
        "section": "S1",
        "esrs": null,
        "type": "Required",
        "text": "Legal name and registered country of the responding entity.",
        "required": true
      },
      {
        "id": "S1-2",
        "row": 7,
        "section": "S1",
        "esrs": null,
        "type": "Required",
        "text": "Primary contact name, title, and email address for this assessment.",
        "required": true
      },
      {
        "id": "S1-3",
        "row": 8,
        "section": "S1",
        "esrs": "Bypass",
        "type": "Dropdown",
        "text": "Do you hold a valid EcoVadis Sustainability Scorecard (issued within the last 12 months)?\n\nIf YES: attach scorecard link in the Notes column and proceed directly to the Status column. Sections S2–S7 are not required.",
        "required": false,
        "options": [
          "Yes — Scorecard Attached",
          "No — Will Complete Questionnaire"
        ]
      },
      {
        "id": "S1-4",
        "row": 9,
        "section": "S1",
        "esrs": null,
        "type": "Conditional",
        "text": "EcoVadis Scorecard Link (if applicable). Paste URL or attach document reference.",
        "required": false
      },
      {
        "id": "S2-1",
        "row": 11,
        "section": "S2",
        "esrs": "E1-4",
        "type": "Quantitative",
        "text": "Total Scope 1 emissions for last fiscal year (metric tonnes CO₂e). Include verification method.",
        "required": false,
        "number": {
          "unit": "tCO2e",
          "note_label": "Verification method and notes"
        }
      },
      {
        "id": "S2-2",
        "row": 12,
        "section": "S2",
        "esrs": "E1-4",
        "type": "Quantitative",
        "text": "Total Scope 2 emissions for last fiscal year — market-based (metric tonnes CO₂e).",
        "required": false,
        "number": {
          "unit": "tCO2e"
        }
      },
      {
        "id": "S2-3",
        "row": 13,
        "section": "S2",
        "esrs": "E1-4",
        "type": "Quantitative",
        "text": "Total Scope 3 emissions for last fiscal year (metric tonnes CO₂e). Specify categories included.",
        "required": false,
        "number": {
          "unit": "tCO2e",
          "note_label": "Categories included and notes"
        }
      },
      {
        "id": "S2-4",
        "row": 14,
        "section": "S2",
        "esrs": "E1-3",
        "type": "Dropdown",
        "text": "Does your organisation have a Science-Based Target (SBTi) validated decarbonisation target?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S2-5",
        "row": 15,
        "section": "S2",
        "esrs": "E1-2",
        "type": "Open-Ended",
        "text": "Describe your top three decarbonisation projects currently in progress or planned for the next 24 months. Include estimated tCO₂e reduction and the specific technology being utilised (e.g., electrification of heat, on-site renewables).",
        "required": false
      },
      {
        "id": "S2-6",
        "row": 16,
        "section": "S2",
        "esrs": "E1-2",
        "type": "Open-Ended",
        "text": "What are the primary technical or financial barriers preventing you from reaching a 50% reduction in Scope 1 and 2 emissions by 2030?",
        "required": false
      },
      {
        "id": "S3-1",
        "row": 18,
        "section": "S3",
        "esrs": "E2-3",
        "type": "Quantitative",
        "text": "Total weight of substances of concern (REACH, SVHC list) used in production last fiscal year (kg).",
        "required": false,
        "number": {
          "unit": "kg"
        }
      },
      {
        "id": "S3-2",
        "row": 19,
        "section": "S3",
        "esrs": "E2-3",
        "type": "Dropdown",
        "text": "Do any of your products or production processes contain or utilise PFAS compounds (\"Forever Chemicals\")?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S3-3",
        "row": 20,
        "section": "S3",
        "esrs": "E2-3",
        "type": "Open-Ended",
        "text": "If your products contain PFAS, detail your substitution roadmap. Have you identified viable non-PFAS alternatives? Provide your target date for a complete phase-out.",
        "required": false
      },
      {
        "id": "S3-4",
        "row": 21,
        "section": "S3",
        "esrs": "E2-2",
        "type": "Open-Ended",
        "text": "Describe your industrial wastewater treatment process. What specific measures are in place to ensure zero leakage of hazardous chemicals into local water systems?",
        "required": false
      },
      {
        "id": "S4-1",
        "row": 23,
        "section": "S4",
        "esrs": "E3-1",
        "type": "Quantitative",
        "text": "Total water withdrawal last fiscal year (m³). Specify source (municipal, groundwater, surface).",
        "required": false,
        "number": {
          "unit": "m3",
          "note_label": "Source and notes"
        }
      },
      {
        "id": "S4-2",
        "row": 24,
        "section": "S4",
        "esrs": "E3-1",
        "type": "Dropdown",
        "text": "Is your primary production facility located in a high-water-stress region (WRI Aqueduct score ≥3)?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S4-3",
        "row": 25,
        "section": "S4",
        "esrs": "E3-2",
        "type": "Open-Ended",
        "text": "Provide details on any water-saving or closed-loop recycling projects implemented at your facility. How has your total water intensity (litres per unit produced) changed over the last three years?",
        "required": false
      },
      {
        "id": "S4-4",
        "row": 26,
        "section": "S4",
        "esrs": "E3-2",
        "type": "Open-Ended",
        "text": "If your facility is in a high-water-stress region, what is your operational contingency plan for severe drought conditions to ensure supply continuity to The Corporate?",
        "required": false
      },
      {
        "id": "S5-1",
        "row": 28,
        "section": "S5",
        "esrs": "E5-2",
        "type": "Quantitative",
        "text": "Total waste generated last fiscal year (tonnes). Breakdown: landfill / recycled / energy recovery / hazardous.",
        "required": false,
        "number": {
          "unit": "tonnes",
          "note_label": "Breakdown and notes"
        }
      },
      {
        "id": "S5-2",
        "row": 29,
        "section": "S5",
        "esrs": "E5-4",
        "type": "Quantitative",
        "text": "Percentage of post-consumer recycled (PCR) content in the components supplied to The Corporate (%).",
        "required": false,
        "number": {
          "unit": "%",
          "max": 100
        }
      },
      {
        "id": "S5-3",
        "row": 30,
        "section": "S5",
        "esrs": "E5-3",
        "type": "Open-Ended",
        "text": "How are you incorporating circularity into the specific components you supply to The Corporate? Examples: design for disassembly, modularity, or increasing PCR content.",
        "required": false
      },
      {
        "id": "S5-4",
        "row": 31,
        "section": "S5",
        "esrs": "E5-2",
        "type": "Open-Ended",
        "text": "Detail your strategy for achieving Zero Waste to Landfill. What are your primary waste streams, and what innovative recycling or upcycling initiatives have you launched recently?",
        "required": false
      },
      {
        "id": "S6-1",
        "row": 33,
        "section": "S6",
        "esrs": "E4-2",
        "type": "Dropdown",
        "text": "Are any of your production sites located within or adjacent to (within 1 km) a protected area or biodiversity hotspot?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S6-2",
        "row": 34,
        "section": "S6",
        "esrs": "E4-3",
        "type": "Open-Ended",
        "text": "Describe any initiatives taken to minimise the impact of your operations on local biodiversity. Include land-use management, native planting schemes, or light/noise pollution reduction.",
        "required": false
      },
      {
        "id": "S6-3",
        "row": 35,
        "section": "S6",
        "esrs": "E4-5",
        "type": "Open-Ended",
        "text": "Have you undertaken a biodiversity impact assessment (TNFD or equivalent) for your primary production sites? If yes, share key findings. If no, provide your target assessment date.",
        "required": false
      },
      {
        "id": "S7-1",
        "row": 37,
        "section": "S7",
        "esrs": "S2-1",
        "type": "Dropdown",
        "text": "Does your organisation have a formal Human Rights and Labour Rights Policy, aligned with the UN Guiding Principles on Business and Human Rights?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S7-2",
        "row": 38,
        "section": "S7",
        "esrs": "S2-2",
        "type": "Dropdown",
        "text": "Have you conducted a human rights due diligence assessment of your Tier 1 and Tier 2 supply chains in the last 24 months?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S7-3",
        "row": 39,
        "section": "S7",
        "esrs": "S2-4",
        "type": "Open-Ended",
        "text": "Describe the grievance mechanism available to workers in your supply chain. How many grievances were filed and resolved in the last 12 months?",
        "required": false
      },
      {
        "id": "S7-4",
        "row": 40,
        "section": "S7",
        "esrs": "G1-1",
        "type": "Dropdown",
        "text": "Does your organisation have a verified conflict minerals policy (3TG — tin, tantalum, tungsten, gold) in place, including OECD Due Diligence guidance compliance?",
        "required": false,
        "options": [
          "Yes",
          "No"
        ]
      },
      {
        "id": "S7-5",
        "row": 41,
        "section": "S7",
        "esrs": "G1-2",
        "type": "Open-Ended",
        "text": "Describe your supplier code of conduct and how compliance is monitored across your own supply chain. Include details of any third-party audits conducted in the last 24 months.",
        "required": false
      }
    ],
    "declaration": "DECLARATION: I confirm that the information provided in this assessment is accurate and complete to the best of my knowledge."
  };

  // The number rule (spec v2.1, Section 9), one definition for the page and the submit function.
  // Accepts digits with an optional decimal point; a comma only as a thousands separator in groups of three.
  // Returns { ok: true, value } with the separators removed ('' when empty), or { ok: false, message }.
  data.NUMBER_MESSAGE = 'Enter a number only, for example 12345 or 12,345.6. Put any other detail in the notes.';
  data.PERCENT_MESSAGE = 'Enter a percentage from 0 to 100.';
  data.parseNumber = function (raw, rule) {
    var s = String(raw == null ? '' : raw).trim();
    if (s === '') return { ok: true, value: '' };
    var max = rule && typeof rule.max === 'number' ? rule.max : null;
    var message = max === null ? data.NUMBER_MESSAGE : data.PERCENT_MESSAGE;
    if (!/^(\d{1,3}(,\d{3})+|\d+)(\.\d+)?$/.test(s)) return { ok: false, message: message };
    var value = s.replace(/,/g, '');
    if (max !== null && Number(value) > max) return { ok: false, message: message };
    return { ok: true, value: value };
  };
  if (typeof module !== 'undefined' && module.exports) { module.exports = data; } else { root.TC_QUESTIONS = data; }
})(typeof window !== 'undefined' ? window : this);
